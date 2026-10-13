import SwiftUI

@MainActor
@Observable
final class CommunityViewModel {
    let feedPagination = PaginationState<CommunityPost>()
    let communitiesPagination = PaginationState<Community>()
    private(set) var isLoadingFeed = false
    private(set) var isLoadingCommunities = false
    private(set) var feedError: String?
    private(set) var communitiesError: String?

    var feed: [CommunityPost] {
        feedPagination.items
    }

    var communities: [Community] {
        communitiesPagination.items
    }

    private let repository: CommunityRepository

    init(repository: CommunityRepository = RemoteCommunityRepository()) {
        self.repository = repository
    }

    func loadFeed(reset: Bool = true) async {
        if reset {
            guard !isLoadingFeed else { return }
            isLoadingFeed = true
            feedError = nil
            feedPagination.reset()
        } else {
            guard feedPagination.canLoadMore else { return }
            feedPagination.setLoading(true)
        }

        let nextPage = feedPagination.currentPage + 1

        do {
            let page = try await repository.fetchPosts(
                page: nextPage,
                perPage: Constants.feedPageSize,
                communityId: nil
            )
            feedPagination.append(page: page)
        } catch {
            if reset { feedError = error.localizedDescription }
        }

        if reset { isLoadingFeed = false }
        feedPagination.setLoading(false)
    }

    func loadMoreFeed() async {
        await loadFeed(reset: false)
    }

    func loadCommunities(search: String? = nil, reset: Bool = true) async {
        if reset {
            guard !isLoadingCommunities else { return }
            isLoadingCommunities = true
            communitiesError = nil
            communitiesPagination.reset()
        } else {
            guard communitiesPagination.canLoadMore else { return }
            communitiesPagination.setLoading(true)
        }

        let nextPage = communitiesPagination.currentPage + 1

        do {
            let page = try await repository.fetchCommunities(
                page: nextPage,
                perPage: Constants.communitiesPageSize,
                search: search
            )
            communitiesPagination.append(page: page)
        } catch {
            if reset { communitiesError = error.localizedDescription }
        }

        if reset { isLoadingCommunities = false }
        communitiesPagination.setLoading(false)
    }

    func loadMoreCommunities(search: String? = nil) async {
        await loadCommunities(search: search, reset: false)
    }

    func toggleLike(_ post: CommunityPost) {
        guard let index = feed.firstIndex(where: { $0.id == post.id }) else { return }
        var updated = feed[index]
        updated.isLiked.toggle()
        updated.likes += updated.isLiked ? 1 : -1
        feedPagination.updateItem(at: index, with: updated)

        Task {
            do {
                let status = try await repository.togglePostLike(id: post.id)
                if let idx = feed.firstIndex(where: { $0.id == post.id }) {
                    var item = feed[idx]
                    item.isLiked = status.isLiked
                    item.likes = status.likes
                    feedPagination.updateItem(at: idx, with: item)
                }
            } catch {
                if let idx = feed.firstIndex(where: { $0.id == post.id }) {
                    var item = feed[idx]
                    item.isLiked.toggle()
                    item.likes += item.isLiked ? 1 : -1
                    feedPagination.updateItem(at: idx, with: item)
                }
            }
        }
    }

    func toggleBookmark(_ post: CommunityPost) {
        guard let index = feed.firstIndex(where: { $0.id == post.id }) else { return }
        var updated = feed[index]
        updated.isBookmarked.toggle()
        feedPagination.updateItem(at: index, with: updated)
    }

    func joinCommunity(_ community: Community) {
        guard let index = communities.firstIndex(where: { $0.id == community.id }) else { return }
        var updated = communities[index]
        updated.isJoined = true
        communitiesPagination.updateItem(at: index, with: updated)

        Task {
            do {
                try await repository.joinCommunity(id: community.id)
            } catch {
                if let idx = communities.firstIndex(where: { $0.id == community.id }) {
                    var item = communities[idx]
                    item.isJoined = false
                    communitiesPagination.updateItem(at: idx, with: item)
                }
            }
        }
    }

    func leaveCommunity(_ community: Community) {
        guard let index = communities.firstIndex(where: { $0.id == community.id }) else { return }
        var updated = communities[index]
        updated.isJoined = false
        communitiesPagination.updateItem(at: index, with: updated)

        Task {
            do {
                try await repository.leaveCommunity(id: community.id)
            } catch {
                if let idx = communities.firstIndex(where: { $0.id == community.id }) {
                    var item = communities[idx]
                    item.isJoined = true
                    communitiesPagination.updateItem(at: idx, with: item)
                }
            }
        }
    }

    func createCommunity(name: String, description: String) async throws -> Community {
        var created = try await repository.createCommunity(title: name, description: description)
        created.isJoined = true
        created.memberCount = Constants.firstMemberCount
        communitiesPagination.insert(created, at: 0)
        return created
    }

    func removeCommunity(id: Int) {
        communitiesPagination.removeAll { $0.id == id }
        feedPagination.removeAll { $0.communityId == id }
    }

    func createPost(title: String, body: String, communityId: Int) async -> CommunityPost? {
        do {
            let post = try await repository.createPost(
                title: title,
                description: body,
                communityId: communityId
            )
            feedPagination.insert(post, at: 0)
            return post
        } catch {
            feedError = error.localizedDescription
            return nil
        }
    }
}

private enum Constants {
    static let feedPageSize = 20
    static let communitiesPageSize = 30
    static let firstMemberCount = 1
}
