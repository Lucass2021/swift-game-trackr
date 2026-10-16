import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct StatsViewModelTests {
    private static let overlapLatency: Duration = .milliseconds(50)

    @Test func loadShowsTheStatsFromTheRepository() async {
        let viewModel = StatsViewModel(repository: FakeStatsRepository(latency: .zero))

        await viewModel.loadIfNeeded()

        #expect(viewModel.stats != nil)
        #expect(!viewModel.isLoading)
        #expect(!viewModel.hasError)
    }

    @Test func loadFailureShowsTheErrorStateInsteadOfLoadingForever() async {
        let viewModel = StatsViewModel(repository: FakeStatsRepository(
            failure: APIError.networkFailure,
            latency: .zero
        ))

        await viewModel.loadIfNeeded()

        #expect(viewModel.hasError)
        #expect(!viewModel.isLoading)
        #expect(viewModel.stats == nil)
    }

    @Test func retryAfterAFailureShowsTheStats() async {
        let repository = FakeStatsRepository(failure: APIError.networkFailure, latency: .zero)
        let viewModel = StatsViewModel(repository: repository)
        await viewModel.loadIfNeeded()

        await repository.setFailure(nil)
        await viewModel.load()

        #expect(viewModel.stats != nil)
        #expect(!viewModel.hasError)
    }

    @Test func returningToTheScreenKeepsTheStatsWithoutFetchingAgain() async {
        let repository = FakeStatsRepository(latency: .zero)
        let viewModel = StatsViewModel(repository: repository)
        await viewModel.loadIfNeeded()

        await viewModel.loadIfNeeded()

        #expect(await repository.fetchCount == 1)
        #expect(viewModel.stats != nil)
    }

    @Test func aSecondLoadReplacesTheOneInFlightWithoutShowingAnError() async {
        let repository = FakeStatsRepository(failure: APIError.networkFailure, latency: Self.overlapLatency)
        let viewModel = StatsViewModel(repository: repository)

        let first = Task { await viewModel.load() }
        while await repository.fetchCount == 0 {
            await Task.yield()
        }
        await repository.setFailure(nil)
        await viewModel.load()
        await first.value

        #expect(viewModel.stats != nil)
        #expect(!viewModel.hasError)
    }
}
