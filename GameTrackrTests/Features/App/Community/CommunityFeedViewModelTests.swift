import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct CommunityFeedViewModelTests {
    private static let posts = CommunityMockData.communityPosts
    private static let overlapLatency: Duration = .milliseconds(50)

    private static func manyPosts() -> [CommunityPost] {
        let base = posts[0]
        return (0 ..< CommunityFeedViewModel.pageSize + 5).map { offset in
            CommunityPost(
                id: 1000 + offset,
                author: base.author,
                timeAgo: base.timeAgo,
                communityName: base.communityName,
                title: base.title,
                preview: base.preview,
                likes: base.likes,
                comments: base.comments,
                hasMedia: false
            )
        }
    }

    private static func viewModel(
        _ repository: FakeCommunityRepository
    ) -> (CommunityFeedViewModel, FakeCommunityFeedRepository) {
        let feedRepository = FakeCommunityFeedRepository(remote: repository, latency: .zero)
        let viewModel = CommunityFeedViewModel(
            feedRepository: feedRepository,
            repository: repository,
            postUpdates: PostUpdates(),
            communityUpdates: CommunityUpdates()
        )
        return (viewModel, feedRepository)
    }

    @Test func loadShowsTheLatestPostsAndTheFirstCommunityNotJoined() async {
        let (viewModel, _) = Self.viewModel(FakeCommunityRepository(latency: .zero))

        await viewModel.loadIfNeeded()

        #expect(viewModel.posts.map(\.id) == Self.posts.map(\.id))
        #expect(viewModel.suggestedCommunity?.id == CommunityMockData.all.first { !$0.isJoined }?.id)
        #expect(!viewModel.isLoading)
    }

    @Test func comingBackToTheFeedDoesNotReloadIt() async {
        let (viewModel, feedRepository) = Self.viewModel(FakeCommunityRepository(latency: .zero))

        await viewModel.loadIfNeeded()
        await viewModel.loadIfNeeded()

        #expect(await feedRepository.fetchFeedCount == 1)
    }

    @Test func refreshKeepsThePostsOnScreenUntilTheNewPageArrives() async {
        let repository = FakeCommunityRepository(latency: Self.overlapLatency)
        let (viewModel, _) = Self.viewModel(repository)
        await viewModel.loadIfNeeded()

        let refreshing = Task { await viewModel.refresh() }
        while await repository.fetchPostsCount < 2 {
            await Task.yield()
        }

        #expect(viewModel.posts.count == Self.posts.count)
        #expect(!viewModel.isEmpty)

        await refreshing.value
    }

    @Test func aRefreshFailureKeepsThePostsAndShowsAToast() async {
        let repository = FakeCommunityRepository(latency: .zero)
        let (viewModel, _) = Self.viewModel(repository)
        await viewModel.loadIfNeeded()

        await repository.setFailure(APIError.networkFailure)
        await viewModel.refresh()

        #expect(viewModel.posts.count == Self.posts.count)
        #expect(!viewModel.hasError)
        #expect(viewModel.toastMessage == "Couldn't refresh. Please try again.")
    }

    @Test func aLoadFailureShowsTheErrorStateAndRetryLoadsThePosts() async {
        let repository = FakeCommunityRepository(failure: APIError.networkFailure, latency: .zero)
        let (viewModel, _) = Self.viewModel(repository)
        await viewModel.loadIfNeeded()

        #expect(viewModel.hasError)

        await repository.setFailure(nil)
        await viewModel.load()

        #expect(!viewModel.hasError)
        #expect(viewModel.posts.count == Self.posts.count)
    }

    @Test func aLoadMoreFailureShowsTheRetryRowAndPausesInfiniteScroll() async {
        let posts = Self.manyPosts()
        let repository = FakeCommunityRepository(posts: posts, latency: .zero)
        let (viewModel, _) = Self.viewModel(repository)
        await viewModel.loadIfNeeded()

        await repository.setFailure(APIError.networkFailure)
        await viewModel.loadMore()

        #expect(viewModel.loadMoreFailed)
        #expect(!viewModel.canLoadMore)

        await repository.setFailure(nil)
        await viewModel.loadMore()

        #expect(viewModel.posts.count == posts.count)
    }

    @Test func topRatedSortsThePostsByLikesAndFollowingShowsTheFollowedPosts() async {
        let (viewModel, _) = Self.viewModel(FakeCommunityRepository(latency: .zero))
        await viewModel.loadIfNeeded()

        await viewModel.onFilterChange(.topRated)

        #expect(viewModel.posts.map(\.id) == Self.posts.sorted { $0.likes > $1.likes }.map(\.id))

        await viewModel.onFilterChange(.following)

        #expect(viewModel.filter == .following)
        #expect(viewModel.posts.map(\.id) == CommunityMockData.feed.map(\.id))
    }
}
