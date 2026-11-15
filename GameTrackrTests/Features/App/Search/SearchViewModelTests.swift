import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct SearchViewModelTests {
    private static let overlapLatency: Duration = .milliseconds(50)
    private static let manyGames = (0 ..< SearchViewModel.pageSize + 5).map { offset in
        Game(id: 100 + offset, name: "Game \(offset)", slug: "game-\(offset)")
    }

    private static func viewModel(
        _ repository: FakeGameRepository,
        debounce: Duration = .zero
    ) -> SearchViewModel {
        SearchViewModel(scope: .all, repository: repository, searchDebounce: debounce)
    }

    @Test func loadShowsTheFirstPageAndThePlatforms() async {
        let viewModel = Self.viewModel(FakeGameRepository(searchResults: Self.manyGames, latency: .zero))

        await viewModel.loadIfNeeded()

        #expect(viewModel.games.count == SearchViewModel.pageSize)
        #expect(viewModel.total == Self.manyGames.count)
        #expect(viewModel.platforms.map(\.slug) == HomeMockData.platforms.map(\.slug))
    }

    @Test func comingBackToSearchDoesNotReloadIt() async {
        let repository = FakeGameRepository(searchResults: Self.manyGames, latency: .zero)
        let viewModel = Self.viewModel(repository)

        await viewModel.loadIfNeeded()
        await viewModel.loadIfNeeded()

        #expect(await repository.searchCount == 1)
    }

    @Test func theEmptyStateWaitsForTheFirstPage() async {
        let repository = FakeGameRepository(searchResults: [], latency: Self.overlapLatency)
        let viewModel = Self.viewModel(repository)

        let loading = Task { await viewModel.loadIfNeeded() }
        while await repository.searchCount == 0 {
            await Task.yield()
        }

        #expect(!viewModel.isEmpty)
        #expect(viewModel.isWaiting)

        await loading.value

        #expect(viewModel.isEmpty)
    }

    @Test func aLoadFailureShowsTheErrorStateInsteadOfNoResultsAndRetryLoads() async {
        let repository = FakeGameRepository(searchResults: Self.manyGames, latency: .zero)
        let viewModel = Self.viewModel(repository)
        await repository.setSearchFailure(APIError.networkFailure)
        await viewModel.loadIfNeeded()

        #expect(viewModel.hasError)
        #expect(!viewModel.isEmpty)

        await repository.setSearchFailure(nil)
        await viewModel.load()

        #expect(!viewModel.hasError)
        #expect(viewModel.games.count == SearchViewModel.pageSize)
    }

    @Test func aLoadMoreFailureShowsTheRetryRowAndPausesInfiniteScroll() async {
        let repository = FakeGameRepository(searchResults: Self.manyGames, latency: .zero)
        let viewModel = Self.viewModel(repository)
        await viewModel.loadIfNeeded()

        await repository.setSearchFailure(APIError.networkFailure)
        await viewModel.loadMore()

        #expect(viewModel.loadMoreFailed)
        #expect(!viewModel.canLoadMore)

        await repository.setSearchFailure(nil)
        await viewModel.loadMore()

        #expect(viewModel.games.count == Self.manyGames.count)
    }
}
