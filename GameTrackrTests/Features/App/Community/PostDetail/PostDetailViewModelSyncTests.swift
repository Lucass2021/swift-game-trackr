import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct PostDetailViewModelSyncTests {
    private static let post = CommunityMockData.communityPosts[0]

    private let repository = FakeCommunityRepository(latency: .zero)
    private let feedRepository: FakeCommunityFeedRepository
    private let postUpdates = PostUpdates()
    private let feed: CommunityFeedViewModel
    private let viewModel: PostDetailViewModel

    init() {
        feedRepository = FakeCommunityFeedRepository(remote: repository, latency: .zero)
        feed = CommunityFeedViewModel(
            feedRepository: feedRepository,
            repository: repository,
            postUpdates: postUpdates,
            communityUpdates: CommunityUpdates()
        )
        viewModel = PostDetailViewModel(
            post: Self.post,
            repository: repository,
            feedRepository: feedRepository,
            postUpdates: postUpdates
        )
    }

    private func feedPost() throws -> CommunityPost {
        try #require(feed.posts.first { $0.id == Self.post.id })
    }

    @Test func aLikeInThePostDetailUpdatesTheFeed() async throws {
        await feed.loadIfNeeded()

        await viewModel.onLike()

        #expect(try feedPost().isLiked == !Self.post.isLiked)
        #expect(try feedPost().likes == viewModel.post.likes)
    }

    @Test func aBookmarkInThePostDetailIsSavedAndUpdatesTheFeed() async throws {
        await feed.loadIfNeeded()

        await viewModel.onBookmark()

        #expect(await feedRepository.isBookmarked(Self.post.id))
        #expect(try feedPost().isBookmarked)
    }

    @Test func aBookmarkFailureInThePostDetailRollsBackAndShowsAnError() async throws {
        await feed.loadIfNeeded()

        await feedRepository.setFailure(APIError.networkFailure)
        await viewModel.onBookmark()

        #expect(!viewModel.post.isBookmarked)
        #expect(try !feedPost().isBookmarked)
        #expect(viewModel.toastMessage == "Couldn't update the bookmark. Please try again.")
    }

    private func post(communityId: Int) -> CommunityPost {
        CommunityPost(
            id: Self.post.id,
            author: Self.post.author,
            timeAgo: Self.post.timeAgo,
            communityName: Self.post.communityName,
            communityId: communityId,
            title: Self.post.title,
            preview: Self.post.preview,
            likes: Self.post.likes,
            comments: Self.post.comments,
            hasMedia: false
        )
    }

    @Test func tappingTheCommunityOpensThePostsOwnCommunity() async throws {
        let community = try #require(CommunityMockData.all.last)
        let viewModel = PostDetailViewModel(
            post: post(communityId: community.id),
            repository: repository,
            feedRepository: feedRepository,
            postUpdates: postUpdates
        )

        await viewModel.onCommunityTap()

        #expect(viewModel.communityToOpen?.id == community.id)

        viewModel.onCommunityOpened()

        #expect(viewModel.communityToOpen == nil)
    }

    @Test func aCommunityThatCannotBeLoadedShowsAnError() async {
        let viewModel = PostDetailViewModel(
            post: post(communityId: 9999),
            repository: repository,
            feedRepository: feedRepository,
            postUpdates: postUpdates
        )

        await viewModel.onCommunityTap()

        #expect(viewModel.communityToOpen == nil)
        #expect(viewModel.toastMessage == "Couldn't open this community. Please try again.")
    }
}
