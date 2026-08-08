import SwiftUI

@MainActor
@Observable
final class CommunityViewModel {
    private(set) var feed: [CommunityPost] = []
    var communities: [Community] = []
    private(set) var isLoadingFeed = false
    private(set) var isLoadingCommunities = false
    private(set) var feedError: String?
    private(set) var communitiesError: String?

    private let service = CommunityService.shared

    func loadFeed() async {
        guard !isLoadingFeed else { return }
        isLoadingFeed = true
        feedError = nil

        do {
            let response = try await service.fetchPosts(perPage: 20)
            feed = response.data.map { CommunityPost(dto: $0) }
        } catch {
            feedError = error.localizedDescription
        }
        isLoadingFeed = false
    }

    func loadCommunities(search: String? = nil) async {
        guard !isLoadingCommunities else { return }
        isLoadingCommunities = true
        communitiesError = nil

        do {
            let response = try await service.fetchCommunities(search: search, perPage: 30)
            communities = response.data.map { Community(dto: $0) }
        } catch {
            communitiesError = error.localizedDescription
        }
        isLoadingCommunities = false
    }

    func toggleLike(_ post: CommunityPost) {
        guard let index = feed.firstIndex(where: { $0.id == post.id }) else { return }
        feed[index].isLiked.toggle()
        feed[index].likes += feed[index].isLiked ? 1 : -1

        Task {
            do {
                let response = try await service.toggleLike(postId: post.id)
                if let idx = feed.firstIndex(where: { $0.id == post.id }) {
                    feed[idx].isLiked = response.isLiked
                    feed[idx].likes = response.likes
                }
            } catch {
                if let idx = feed.firstIndex(where: { $0.id == post.id }) {
                    feed[idx].isLiked.toggle()
                    feed[idx].likes += feed[idx].isLiked ? 1 : -1
                }
            }
        }
    }

    func toggleBookmark(_ post: CommunityPost) {
        guard let index = feed.firstIndex(where: { $0.id == post.id }) else { return }
        feed[index].isBookmarked.toggle()
    }

    func joinCommunity(_ community: Community) {
        guard let index = communities.firstIndex(where: { $0.id == community.id }) else { return }
        communities[index].isJoined = true

        Task {
            do {
                _ = try await service.join(communityId: community.id)
            } catch {
                if let idx = communities.firstIndex(where: { $0.id == community.id }) {
                    communities[idx].isJoined = false
                }
            }
        }
    }

    func leaveCommunity(_ community: Community) {
        guard let index = communities.firstIndex(where: { $0.id == community.id }) else { return }
        communities[index].isJoined = false

        Task {
            do {
                _ = try await service.leave(communityId: community.id)
            } catch {
                if let idx = communities.firstIndex(where: { $0.id == community.id }) {
                    communities[idx].isJoined = true
                }
            }
        }
    }

    func toggleJoin(_ community: Community) {
        if community.isJoined {
            leaveCommunity(community)
        } else {
            joinCommunity(community)
        }
    }

    func createPost(title: String, body: String, communityId: Int) async -> CommunityPost? {
        do {
            let dto = try await service.createPost(
                title: title,
                description: body,
                communityId: communityId
            )
            let post = CommunityPost(dto: dto)
            feed.insert(post, at: 0)
            return post
        } catch {
            feedError = error.localizedDescription
            return nil
        }
    }
}
