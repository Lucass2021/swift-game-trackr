import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct AchievementsViewModelTests {
    private static let overlapLatency: Duration = .milliseconds(50)
    private static let ids = AchievementsMockData.games.map(\.id)
    private static let firstPage = Array(ids.prefix(AchievementsViewModel.pageSize))
    private static let inProgress = AchievementsMockData.games
        .filter { !$0.isComplete && $0.unlockedCount > 0 }
        .map(\.id)

    @Test func loadShowsTheFirstPageAndTheSummary() async {
        let viewModel = AchievementsViewModel(repository: FakeAchievementsRepository(latency: .zero))

        await viewModel.loadIfNeeded()
        await waitUntil { viewModel.summary != nil }

        #expect(viewModel.games.map(\.id) == Self.firstPage)
        #expect(viewModel.showsSummary)
        #expect(viewModel.canLoadMore)
    }

    @Test func loadFailureShowsTheErrorStateInsteadOfLoadingForever() async {
        let viewModel = AchievementsViewModel(repository: FakeAchievementsRepository(
            failure: APIError.networkFailure,
            latency: .zero
        ))

        await viewModel.loadIfNeeded()

        #expect(viewModel.hasError)
        #expect(!viewModel.isLoading)
    }

    @Test func retryAfterAFailureShowsTheGames() async {
        let repository = FakeAchievementsRepository(failure: APIError.networkFailure, latency: .zero)
        let viewModel = AchievementsViewModel(repository: repository)
        await viewModel.loadIfNeeded()

        await repository.setFailure(nil)
        await viewModel.load()

        #expect(viewModel.games.map(\.id) == Self.firstPage)
        #expect(!viewModel.hasError)
    }

    @Test func returningToTheScreenKeepsTheGamesWithoutFetchingAgain() async {
        let repository = FakeAchievementsRepository(latency: .zero)
        let viewModel = AchievementsViewModel(repository: repository)
        await viewModel.loadIfNeeded()

        await viewModel.loadIfNeeded()

        #expect(await repository.fetchCount == 1)
        #expect(viewModel.games.map(\.id) == Self.firstPage)
    }

    @Test func filteringFindsMatchingGamesBeyondTheFirstPage() async {
        let viewModel = AchievementsViewModel(repository: FakeAchievementsRepository(latency: .zero))
        await viewModel.loadIfNeeded()
        await waitUntil { viewModel.summary != nil }

        await viewModel.onFilterChange(.inProgress)

        #expect(viewModel.games.map(\.id) == Array(Self.inProgress.prefix(AchievementsViewModel.pageSize)))
        #expect(!viewModel.showsSummary)
    }

    @Test func aFilterChangeReplacesTheLoadInFlight() async {
        let repository = FakeAchievementsRepository(latency: Self.overlapLatency)
        let viewModel = AchievementsViewModel(repository: repository)

        let loading = Task { await viewModel.loadIfNeeded() }
        while await repository.fetchCount == 0 {
            await Task.yield()
        }
        await viewModel.onFilterChange(.inProgress)
        await loading.value

        #expect(viewModel.games.map(\.id) == Array(Self.inProgress.prefix(AchievementsViewModel.pageSize)))
    }

    @Test func loadingMoreAppendsTheNextPageUntilTheLastOne() async {
        let viewModel = AchievementsViewModel(repository: FakeAchievementsRepository(latency: .zero))
        await viewModel.loadIfNeeded()

        await viewModel.loadMore()

        #expect(viewModel.games.map(\.id) == Self.ids)
        #expect(!viewModel.canLoadMore)
    }

    @Test func aLoadMoreFailureKeepsTheGamesAndStopsUntilRetried() async {
        let repository = FakeAchievementsRepository(latency: .zero)
        let viewModel = AchievementsViewModel(repository: repository)
        await viewModel.loadIfNeeded()

        await repository.setFailure(APIError.networkFailure)
        await viewModel.loadMore()

        #expect(viewModel.loadMoreFailed)
        #expect(!viewModel.canLoadMore)
        #expect(viewModel.games.map(\.id) == Self.firstPage)

        await repository.setFailure(nil)
        await viewModel.loadMore()

        #expect(!viewModel.loadMoreFailed)
        #expect(viewModel.games.map(\.id) == Self.ids)
    }

    private func waitUntil(_ condition: () async -> Bool) async {
        while await !condition() {
            await Task.yield()
        }
    }
}
