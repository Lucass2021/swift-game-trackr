import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct DiscoverCommunitiesViewModelTests {
    private static let overlapLatency: Duration = .milliseconds(50)
    private static let searchDebounce: Duration = .seconds(1)

    private static func manyCommunities() -> [Community] {
        (0 ..< DiscoverCommunitiesViewModel.pageSize + 5).map { offset in
            Community(id: 500 + offset, name: "Community \(offset)")
        }
    }

    private static func viewModel(
        _ remote: FakeCommunityRepository,
        debounce: Duration = .zero
    ) -> (DiscoverCommunitiesViewModel, FakeDiscoverCommunitiesRepository) {
        let repository = FakeDiscoverCommunitiesRepository(remote: remote, latency: .zero)
        let viewModel = DiscoverCommunitiesViewModel(
            repository: repository,
            communityUpdates: CommunityUpdates(),
            searchDebounce: debounce
        )
        return (viewModel, repository)
    }

    @Test func loadShowsTheRealCommunities() async {
        let (viewModel, _) = Self.viewModel(FakeCommunityRepository(latency: .zero))

        await viewModel.loadIfNeeded()

        #expect(viewModel.communities.map(\.id) == CommunityMockData.all.map(\.id))
    }

    @Test func theEmptyStateWaitsForTheFirstPage() async {
        let remote = FakeCommunityRepository(communities: [], latency: Self.overlapLatency)
        let (viewModel, repository) = Self.viewModel(remote)

        let loading = Task { await viewModel.loadIfNeeded() }
        while await repository.fetchCount == 0 {
            await Task.yield()
        }

        #expect(!viewModel.isEmpty)

        await loading.value

        #expect(viewModel.isEmpty)
    }

    @Test func comingBackToDiscoverDoesNotReloadIt() async {
        let (viewModel, repository) = Self.viewModel(FakeCommunityRepository(latency: .zero))

        await viewModel.loadIfNeeded()
        await viewModel.loadIfNeeded()

        #expect(await repository.fetchCount == 1)
    }

    @Test func aLoadFailureShowsTheErrorStateAndRetryLoadsTheCommunities() async {
        let (viewModel, repository) = Self.viewModel(FakeCommunityRepository(latency: .zero))
        await repository.setFailure(APIError.networkFailure)
        await viewModel.loadIfNeeded()

        #expect(viewModel.hasError)

        await repository.setFailure(nil)
        await viewModel.load()

        #expect(!viewModel.hasError)
        #expect(!viewModel.communities.isEmpty)
    }

    @Test func aLoadMoreFailureShowsTheRetryRowAndPausesInfiniteScroll() async {
        let communities = Self.manyCommunities()
        let (viewModel, repository) = Self.viewModel(FakeCommunityRepository(communities: communities, latency: .zero))
        await viewModel.loadIfNeeded()

        await repository.setFailure(APIError.networkFailure)
        await viewModel.loadMore()

        #expect(viewModel.loadMoreFailed)
        #expect(!viewModel.canLoadMore)

        await repository.setFailure(nil)
        await viewModel.loadMore()

        #expect(viewModel.communities.count == communities.count)
    }

    @Test func typingASearchAsksTheRepositoryOnceAfterThePause() async {
        let (viewModel, repository) = Self.viewModel(
            FakeCommunityRepository(latency: .zero),
            debounce: Self.searchDebounce
        )
        await viewModel.loadIfNeeded()

        let keystrokes = ["r", "rp", "rpg"].map { viewModel.onQueryChange($0) }
        for keystroke in keystrokes {
            await keystroke.value
        }

        #expect(await repository.fetchCount == 2)
        #expect(await repository.lastSearch == "rpg")
    }

    @Test func aCategoryShowsTheCommunitiesOfThatCategory() async {
        let (viewModel, _) = Self.viewModel(FakeCommunityRepository(latency: .zero))
        await viewModel.loadIfNeeded()

        await viewModel.onCategoryChange("RPG")

        let expected = DiscoverMockData.categoryCommunities.filter { $0.category == "RPG" }.map(\.id)
        #expect(viewModel.communities.map(\.id) == expected)
    }

    @Test func aLoadMoreWhileASearchIsPendingKeepsTheLoadedSearch() async {
        let remote = FakeCommunityRepository(communities: Self.manyCommunities(), latency: .zero)
        let (viewModel, repository) = Self.viewModel(remote, debounce: Self.searchDebounce)
        await viewModel.loadIfNeeded()

        let search = viewModel.onQueryChange("rpg")
        await viewModel.loadMore()

        #expect(await repository.lastSearch == nil)
        search.cancel()
    }

    @Test func anOlderPageDoesNotReplaceANewerCategory() async {
        let remote = FakeCommunityRepository(latency: Self.overlapLatency)
        let (viewModel, repository) = Self.viewModel(remote)

        let loading = Task { await viewModel.loadIfNeeded() }
        while await repository.fetchCount == 0 {
            await Task.yield()
        }
        await viewModel.onCategoryChange("RPG")
        await loading.value

        #expect(!viewModel.communities.isEmpty)
        #expect(viewModel.communities.allSatisfy { $0.category == "RPG" })
    }
}
