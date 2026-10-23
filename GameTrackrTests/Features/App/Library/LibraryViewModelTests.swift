import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct LibraryViewModelTests {
    private static let userId = 7
    private static let overlapLatency: Duration = .milliseconds(50)
    private static let slugs = LibraryMockData.entries.map(\.slug)
    private static let firstPage = Array(slugs.prefix(LibraryViewModel.pageSize))

    @Test func loadingForAUserShowsTheFirstPageAndTheStats() async {
        let viewModel = LibraryViewModel(
            repository: FakeLibraryRepository(latency: .zero),
            libraryUpdates: LibraryUpdates()
        )

        await viewModel.loadFor(Self.userId)
        await waitForStats(viewModel)

        #expect(viewModel.entries.map(\.slug) == Self.firstPage)
        #expect(viewModel.stats?.totalGames == LibraryMockData.stats.totalGames)
        #expect(viewModel.canLoadMore)
    }

    @Test func loadFailureShowsTheErrorStateInsteadOfLoadingForever() async {
        let viewModel = LibraryViewModel(
            repository: FakeLibraryRepository(
                failure: APIError.networkFailure,
                latency: .zero
            ),
            libraryUpdates: LibraryUpdates()
        )

        await viewModel.loadFor(Self.userId)

        #expect(viewModel.hasError)
        #expect(!viewModel.isLoading)
    }

    @Test func retryAfterAFailureShowsTheEntries() async {
        let repository = FakeLibraryRepository(failure: APIError.networkFailure, latency: .zero)
        let viewModel = LibraryViewModel(repository: repository, libraryUpdates: LibraryUpdates())
        await viewModel.loadFor(Self.userId)

        await repository.setFailure(nil)
        await viewModel.load()

        #expect(viewModel.entries.map(\.slug) == Self.firstPage)
        #expect(!viewModel.hasError)
    }

    @Test func comingBackToTheTabKeepsTheEntriesWithoutFetchingAgain() async {
        let repository = FakeLibraryRepository(latency: .zero)
        let viewModel = LibraryViewModel(repository: repository, libraryUpdates: LibraryUpdates())
        await viewModel.loadFor(Self.userId)

        await viewModel.loadFor(Self.userId)

        #expect(await repository.fetchCount == 1)
        #expect(viewModel.entries.map(\.slug) == Self.firstPage)
    }

    @Test func switchingToAGuestDropsTheEntriesAndALateResultDoesNotBringThemBack() async {
        let repository = FakeLibraryRepository(latency: Self.overlapLatency)
        let viewModel = LibraryViewModel(repository: repository, libraryUpdates: LibraryUpdates())

        let loading = Task { await viewModel.loadFor(Self.userId) }
        await waitForFetch(repository)
        await viewModel.loadFor(nil)
        await loading.value

        #expect(viewModel.entries.isEmpty)
        #expect(viewModel.currentPage == 0)
        #expect(!viewModel.isLoading)
        #expect(!viewModel.hasError)
    }

    @Test func filteringFindsMatchingGamesBeyondTheFirstPage() async {
        let viewModel = LibraryViewModel(
            repository: FakeLibraryRepository(latency: .zero),
            libraryUpdates: LibraryUpdates()
        )
        await viewModel.loadFor(Self.userId)

        await viewModel.onFilterChange(.platinum)

        #expect(viewModel.entries.map(\.slug) == slugs(with: .platinum))
        #expect(viewModel.filter == .platinum)
    }

    @Test func aFilterChangeReplacesTheLoadInFlight() async {
        let repository = FakeLibraryRepository(latency: Self.overlapLatency)
        let viewModel = LibraryViewModel(repository: repository, libraryUpdates: LibraryUpdates())

        let loading = Task { await viewModel.loadFor(Self.userId) }
        await waitForFetch(repository)
        await viewModel.onFilterChange(.playing)
        await loading.value

        #expect(viewModel.entries.map(\.slug) == slugs(with: .playing))
    }

    @Test func loadingMoreAppendsTheNextPageUntilTheLastOne() async {
        let viewModel = LibraryViewModel(
            repository: FakeLibraryRepository(latency: .zero),
            libraryUpdates: LibraryUpdates()
        )
        await viewModel.loadFor(Self.userId)

        await viewModel.loadMore()

        #expect(viewModel.entries.map(\.slug) == Self.slugs)
        #expect(!viewModel.canLoadMore)
    }

    @Test func aLoadMoreFailureKeepsTheEntriesAndStopsUntilRetried() async {
        let repository = FakeLibraryRepository(latency: .zero)
        let viewModel = LibraryViewModel(repository: repository, libraryUpdates: LibraryUpdates())
        await viewModel.loadFor(Self.userId)

        await repository.setFailure(APIError.networkFailure)
        await viewModel.loadMore()

        #expect(viewModel.loadMoreFailed)
        #expect(!viewModel.canLoadMore)
        #expect(viewModel.entries.map(\.slug) == Self.firstPage)

        await repository.setFailure(nil)
        await viewModel.loadMore()

        #expect(!viewModel.loadMoreFailed)
        #expect(viewModel.entries.map(\.slug) == Self.slugs)
    }

    @Test func anEmptyLibraryOpenedWithAFilterShowsTheEmptyLibraryState() async {
        let repository = FakeLibraryRepository(
            entries: [],
            stats: LibraryStats(totalGames: 0, platinum: 0),
            latency: .zero
        )
        let viewModel = LibraryViewModel(repository: repository, libraryUpdates: LibraryUpdates())
        await viewModel.loadFor(Self.userId)
        await waitForStats(viewModel)

        await viewModel.onFilterChange(.platinum)

        #expect(viewModel.isLibraryEmpty)
    }

    private func slugs(with status: LibraryStatus) -> [String] {
        LibraryMockData.entries.filter { $0.status == status }.map(\.slug)
    }

    private func waitForFetch(_ repository: FakeLibraryRepository) async {
        while await repository.fetchCount == 0 {
            await Task.yield()
        }
    }

    private func waitForStats(_ viewModel: LibraryViewModel) async {
        await waitUntil { viewModel.stats != nil }
    }

    private func waitUntil(_ condition: () async -> Bool) async {
        while await !condition() {
            await Task.yield()
        }
    }
}
