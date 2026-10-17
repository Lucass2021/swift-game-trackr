import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct ProfileViewModelTests {
    private static let userId = 1
    private static let otherUserId = 2
    private static let overlapLatency: Duration = .milliseconds(50)

    @Test func loadingForAUserShowsTheOverviewWithTheStats() async {
        let viewModel = ProfileViewModel(repository: FakeProfileOverviewRepository(latency: .zero))

        await viewModel.loadFor(Self.userId)

        #expect(viewModel.overview?.stats.totalGames == ProfileMockData.stats.totalGames)
        #expect(viewModel.overview?.breakdown.count == ProfileMockData.breakdown.count)
        #expect(!viewModel.isLoading)
    }

    @Test func aGuestDoesNotLoadTheOverview() async {
        let repository = FakeProfileOverviewRepository(latency: .zero)
        let viewModel = ProfileViewModel(repository: repository)

        await viewModel.loadFor(nil)

        #expect(await repository.fetchCount == 0)
        #expect(viewModel.overview == nil)
    }

    @Test func loadFailureShowsTheErrorStateInsteadOfLoadingForever() async {
        let viewModel = ProfileViewModel(repository: FakeProfileOverviewRepository(
            failure: APIError.networkFailure,
            latency: .zero
        ))

        await viewModel.loadFor(Self.userId)

        #expect(viewModel.hasError)
        #expect(!viewModel.isLoading)
    }

    @Test func retryAfterAFailureShowsTheOverview() async {
        let repository = FakeProfileOverviewRepository(failure: APIError.networkFailure, latency: .zero)
        let viewModel = ProfileViewModel(repository: repository)
        await viewModel.loadFor(Self.userId)

        await repository.setFailure(nil)
        await viewModel.load()

        #expect(viewModel.overview?.stats.totalGames == ProfileMockData.stats.totalGames)
        #expect(!viewModel.hasError)
    }

    @Test func comingBackToTheTabKeepsTheOverviewWithoutFetchingAgain() async {
        let repository = FakeProfileOverviewRepository(latency: .zero)
        let viewModel = ProfileViewModel(repository: repository)
        await viewModel.loadFor(Self.userId)

        await viewModel.loadFor(Self.userId)

        #expect(await repository.fetchCount == 1)
        #expect(viewModel.overview != nil)
    }

    @Test func switchingToAnotherUserLoadsTheOverviewAgain() async {
        let repository = FakeProfileOverviewRepository(latency: .zero)
        let viewModel = ProfileViewModel(repository: repository)
        await viewModel.loadFor(Self.userId)

        await viewModel.loadFor(Self.otherUserId)

        #expect(await repository.fetchCount == 2)
        #expect(viewModel.overview != nil)
    }

    @Test func switchingToAGuestDropsTheOverviewAndALateResultDoesNotBringItBack() async {
        let repository = FakeProfileOverviewRepository(latency: Self.overlapLatency)
        let viewModel = ProfileViewModel(repository: repository)

        let loading = Task { await viewModel.loadFor(Self.userId) }
        while await repository.fetchCount == 0 {
            await Task.yield()
        }
        await viewModel.loadFor(nil)
        await loading.value

        #expect(viewModel.overview == nil)
        #expect(!viewModel.isLoading)
        #expect(!viewModel.hasError)
    }
}
