import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct CommunityDetailViewModelTests {
    private static let community = CommunityMockData.detailCommunity
    private static let overlapLatency: Duration = .milliseconds(50)

    private static func manyPosts() -> [CommunityPost] {
        let base = CommunityMockData.communityPosts[0]
        return (0 ..< CommunityDetailViewModel.pageSize + 5).map { offset in
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

    private static func viewModel(_ repository: FakeCommunityRepository) -> CommunityDetailViewModel {
        CommunityDetailViewModel(
            community: community,
            repository: repository,
            feedRepository: FakeCommunityFeedRepository(remote: repository, latency: .zero),
            postUpdates: PostUpdates(),
            communityUpdates: CommunityUpdates()
        )
    }

    @Test func loadShowsThePostsAndTheMembers() async {
        let viewModel = Self.viewModel(FakeCommunityRepository(latency: .zero))

        await viewModel.loadIfNeeded()

        #expect(viewModel.posts.map(\.id) == CommunityMockData.communityPosts.map(\.id))
        #expect(viewModel.members.map(\.id) == CommunityMockData.members.map(\.id))
        #expect(!viewModel.isLoading)
    }

    @Test func theEmptyStateWaitsForTheFirstPage() async {
        let repository = FakeCommunityRepository(posts: [], latency: Self.overlapLatency)
        let viewModel = Self.viewModel(repository)

        let loading = Task { await viewModel.loadIfNeeded() }
        while await repository.fetchPostsCount == 0 {
            await Task.yield()
        }

        #expect(!viewModel.isEmpty)

        await loading.value

        #expect(viewModel.isEmpty)
    }

    @Test func loadFailureShowsTheErrorStateInsteadOfLoadingForever() async {
        let viewModel = Self.viewModel(FakeCommunityRepository(failure: APIError.networkFailure, latency: .zero))

        await viewModel.loadIfNeeded()

        #expect(viewModel.hasError)
        #expect(!viewModel.isLoading)
    }

    @Test func aRetryAfterALoadFailureReloadsPostsAndMembers() async {
        let repository = FakeCommunityRepository(failure: APIError.networkFailure, latency: .zero)
        let viewModel = Self.viewModel(repository)
        await viewModel.loadIfNeeded()

        await repository.setFailure(nil)
        await viewModel.load()

        #expect(!viewModel.hasError)
        #expect(!viewModel.membersFailed)
        #expect(!viewModel.posts.isEmpty)
        #expect(viewModel.members.map(\.id) == CommunityMockData.members.map(\.id))
        #expect(await repository.fetchMembersCount == 2)
    }

    @Test func leavingTheScreenWhileMembersLoadDoesNotShowAnError() async {
        let repository = FakeCommunityRepository(latency: Self.overlapLatency)
        let viewModel = Self.viewModel(repository)

        let loading = Task { await viewModel.loadIfNeeded() }
        while await repository.fetchMembersCount == 0 {
            await Task.yield()
        }
        loading.cancel()
        await loading.value

        #expect(!viewModel.membersFailed)
    }

    @Test func aLoadMoreFailureShowsTheRetryRowAndPausesInfiniteScroll() async {
        let posts = Self.manyPosts()
        let repository = FakeCommunityRepository(posts: posts, latency: .zero)
        let viewModel = Self.viewModel(repository)
        await viewModel.loadIfNeeded()

        await repository.setFailure(APIError.networkFailure)
        await viewModel.loadMore()

        #expect(viewModel.loadMoreFailed)
        #expect(!viewModel.canLoadMore)
        #expect(viewModel.posts.count == CommunityDetailViewModel.pageSize)

        await repository.setFailure(nil)
        await viewModel.loadMore()

        #expect(viewModel.posts.count == posts.count)
    }

    @Test func aMembersFailureShowsTheMembersErrorAndRetryLoadsThem() async {
        let repository = FakeCommunityRepository(failure: APIError.networkFailure, latency: .zero)
        let viewModel = Self.viewModel(repository)
        await viewModel.loadIfNeeded()

        #expect(viewModel.membersFailed)

        await repository.setFailure(nil)
        await viewModel.retryMembers()

        #expect(!viewModel.membersFailed)
        #expect(viewModel.members.map(\.id) == CommunityMockData.members.map(\.id))
    }

    @Test func refreshReloadsTheFirstPageAndKeepsThePostsWhileLoading() async {
        let repository = FakeCommunityRepository(latency: Self.overlapLatency)
        let viewModel = Self.viewModel(repository)
        await viewModel.loadIfNeeded()

        let refreshing = Task { await viewModel.refresh() }
        while await repository.fetchPostsCount < 2 {
            await Task.yield()
        }

        #expect(!viewModel.posts.isEmpty)

        await refreshing.value

        #expect(await repository.fetchPostsCount == 2)
    }

    @Test func returningToTheScreenKeepsThePostsWithoutFetchingAgain() async {
        let repository = FakeCommunityRepository(latency: .zero)
        let viewModel = Self.viewModel(repository)
        await viewModel.loadIfNeeded()

        await viewModel.loadIfNeeded()

        #expect(await repository.fetchPostsCount == 1)
        #expect(await repository.fetchMembersCount == 1)
    }
}
