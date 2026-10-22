import SwiftUI

@MainActor
@Observable
final class CommunityViewModel {
    let communitiesPagination = PaginationState<Community>()
    private(set) var isLoadingCommunities = false
    private(set) var communitiesError: String?

    var communities: [Community] {
        communitiesPagination.items
    }

    private let repository: CommunityRepository

    private let communityUpdates: CommunityUpdates

    init(repository: CommunityRepository = RemoteCommunityRepository(), communityUpdates: CommunityUpdates) {
        self.repository = repository
        self.communityUpdates = communityUpdates
        communityUpdates.observe(self) { [weak self] join in
            guard let self, let index = communities.firstIndex(where: { $0.id == join.communityId }) else { return }
            var updated = communities[index]
            updated.isJoined = join.isJoined
            communitiesPagination.updateItem(at: index, with: updated)
        }
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

    func joinCommunity(_ community: Community) {
        guard let index = communities.firstIndex(where: { $0.id == community.id }) else { return }
        var updated = communities[index]
        updated.isJoined = true
        communitiesPagination.updateItem(at: index, with: updated)

        Task {
            do {
                try await repository.joinCommunity(id: community.id)
                communityUpdates.publish(communityId: community.id, isJoined: true)
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
                communityUpdates.publish(communityId: community.id, isJoined: false)
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
    }

    func createPost(title: String, body: String, communityId: Int) async -> CommunityPost? {
        try? await repository.createPost(title: title, description: body, communityId: communityId)
    }
}

private enum Constants {
    static let communitiesPageSize = 30
    static let firstMemberCount = 1
}
