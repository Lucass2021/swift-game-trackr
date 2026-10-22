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
}
