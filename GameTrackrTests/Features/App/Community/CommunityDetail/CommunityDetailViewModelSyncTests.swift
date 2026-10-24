import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct CommunityDetailViewModelSyncTests {
    private static let community = CommunityMockData.detailCommunity
    private static let post = CommunityMockData.communityPosts[0]
    private static let createdPostId = 9001
    private static let otherPostId = 9002

    private let repository = FakeCommunityRepository(communities: [Self.community], latency: .zero)
    private let postUpdates = PostUpdates()
    private let viewModel: CommunityDetailViewModel

    init() {
        viewModel = CommunityDetailViewModel(
            community: Self.community,
            repository: repository,
            feedRepository: FakeCommunityFeedRepository(remote: repository, latency: .zero),
            postUpdates: postUpdates,
            communityUpdates: CommunityUpdates()
        )
    }

    @Test func aPostChangedInAnotherScreenIsUpdatedInTheCommunityPosts() async {
        await viewModel.loadIfNeeded()
        var changed = Self.post
        changed.isLiked = !Self.post.isLiked
        changed.likes = Self.post.likes + 1

        postUpdates.publish(changed)

        #expect(likedPost().isLiked == !Self.post.isLiked)
        #expect(likedPost().likes == Self.post.likes + 1)
    }

    @Test func aPostCreatedForThisCommunityIsAddedToTheTopOfItsPosts() async {
        await viewModel.loadIfNeeded()

        postUpdates.publishCreated(post(id: Self.createdPostId, communityId: Self.community.id))
        postUpdates.publishCreated(post(id: Self.otherPostId, communityId: Self.community.id + 1))

        #expect(viewModel.posts.first?.id == Self.createdPostId)
        #expect(!viewModel.posts.contains { $0.id == Self.otherPostId })
    }

    private func likedPost() -> CommunityPost {
        viewModel.posts.first { $0.id == Self.post.id } ?? Self.post
    }

    private func post(id: Int, communityId: Int) -> CommunityPost {
        CommunityPost(
            id: id,
            author: Self.post.author,
            timeAgo: Self.post.timeAgo,
            communityName: Self.post.communityName,
            communityId: communityId,
            title: Self.post.title,
            preview: Self.post.preview,
            likes: 0,
            comments: 0,
            hasMedia: false
        )
    }
}
