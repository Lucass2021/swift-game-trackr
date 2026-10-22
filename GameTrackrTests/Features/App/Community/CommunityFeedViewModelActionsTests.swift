import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct CommunityFeedViewModelActionsTests {
    private static let post = CommunityMockData.communityPosts[0]
    private static let overlapLatency: Duration = .milliseconds(50)

    private let repository = FakeCommunityRepository(latency: .zero)
    private let feedRepository: FakeCommunityFeedRepository
    private let postUpdates = PostUpdates()
    private let viewModel: CommunityFeedViewModel

    init() {
        feedRepository = FakeCommunityFeedRepository(remote: repository, latency: .zero)
        viewModel = CommunityFeedViewModel(
            feedRepository: feedRepository,
            repository: repository,
            postUpdates: postUpdates,
            communityUpdates: CommunityUpdates()
        )
    }

    private func feedPost() throws -> CommunityPost {
        try #require(viewModel.posts.first { $0.id == Self.post.id })
    }

    @Test func aLikeIsSavedAndSharedWithTheOtherScreens() async throws {
        await viewModel.loadIfNeeded()
        let listener = CommunityFeedViewModel(
            feedRepository: feedRepository,
            repository: repository,
            postUpdates: postUpdates,
            communityUpdates: CommunityUpdates()
        )
        listener.onPostCreated(Self.post)

        await viewModel.onLike(Self.post.id)

        #expect(try feedPost().isLiked == !Self.post.isLiked)
        #expect(await repository.post(Self.post.id)?.isLiked == !Self.post.isLiked)
        #expect(listener.posts.first?.isLiked == !Self.post.isLiked)
    }

    @Test func aLikeFailureRollsBackAndShowsAnError() async throws {
        await viewModel.loadIfNeeded()

        await repository.setFailure(APIError.networkFailure)
        await viewModel.onLike(Self.post.id)

        #expect(try feedPost().isLiked == Self.post.isLiked)
        #expect(try feedPost().likes == Self.post.likes)
        #expect(viewModel.toastMessage == "Couldn't update the like. Please try again.")
    }

    @Test func aDoubleTapOnLikeSendsOneRequest() async {
        let repository = FakeCommunityRepository(latency: Self.overlapLatency)
        let viewModel = CommunityFeedViewModel(
            feedRepository: FakeCommunityFeedRepository(remote: repository, latency: .zero),
            repository: repository,
            postUpdates: PostUpdates(),
            communityUpdates: CommunityUpdates()
        )
        await viewModel.loadIfNeeded()

        async let first: Void = viewModel.onLike(Self.post.id)
        async let second: Void = viewModel.onLike(Self.post.id)
        _ = await (first, second)

        #expect(await repository.likeCount == 1)
    }

    @Test func aBookmarkIsSavedAndSurvivesAReload() async throws {
        await viewModel.loadIfNeeded()

        await viewModel.onBookmark(Self.post.id)
        await viewModel.refresh()

        #expect(await feedRepository.isBookmarked(Self.post.id))
        #expect(try feedPost().isBookmarked)
    }

    @Test func aBookmarkFailureRollsBackAndShowsAnError() async throws {
        await viewModel.loadIfNeeded()

        await feedRepository.setFailure(APIError.networkFailure)
        await viewModel.onBookmark(Self.post.id)

        #expect(try !feedPost().isBookmarked)
        #expect(viewModel.toastMessage == "Couldn't update the bookmark. Please try again.")
    }

    @Test func aPostChangedInAnotherScreenIsUpdatedInTheFeed() async throws {
        await viewModel.loadIfNeeded()
        var changed = Self.post
        changed.isLiked = !Self.post.isLiked
        changed.likes = Self.post.likes + 1
        changed.isBookmarked = true

        postUpdates.publish(changed)

        #expect(try feedPost().isLiked == !Self.post.isLiked)
        #expect(try feedPost().likes == Self.post.likes + 1)
        #expect(try feedPost().isBookmarked)
    }

    @Test func createdDeletedAndRemovedCommunityPostsUpdateTheFeed() async {
        await viewModel.loadIfNeeded()
        let created = CommunityPost(
            id: 9999,
            author: Self.post.author,
            timeAgo: Self.post.timeAgo,
            communityName: Self.post.communityName,
            communityId: 77,
            title: Self.post.title,
            preview: Self.post.preview,
            likes: 0,
            comments: 0,
            hasMedia: false
        )

        viewModel.onPostCreated(created)
        #expect(viewModel.posts.first?.id == created.id)

        viewModel.onCommunityRemoved(77)
        #expect(!viewModel.posts.contains { $0.communityId == 77 })

        viewModel.onPostCreated(created)
        viewModel.onPostDeleted(created.id)
        #expect(!viewModel.posts.contains { $0.id == created.id })
    }

    @Test func joiningTheSuggestedCommunitySavesItAndAFailureRollsBack() async throws {
        await viewModel.loadIfNeeded()
        let suggestion = try #require(viewModel.suggestedCommunity)

        await viewModel.onJoinSuggested()

        #expect(viewModel.suggestedCommunity?.isJoined == true)
        #expect(await repository.isJoined(suggestion.id))

        let failing = FakeCommunityRepository(latency: .zero)
        let failingViewModel = CommunityFeedViewModel(
            feedRepository: FakeCommunityFeedRepository(remote: failing, latency: .zero),
            repository: failing,
            postUpdates: PostUpdates(),
            communityUpdates: CommunityUpdates()
        )
        await failingViewModel.loadIfNeeded()
        await failing.setFailure(APIError.networkFailure)
        await failingViewModel.onJoinSuggested()

        #expect(failingViewModel.suggestedCommunity?.isJoined != true)
        #expect(failingViewModel.toastMessage == "Couldn't join this community. Please try again.")
    }
}
