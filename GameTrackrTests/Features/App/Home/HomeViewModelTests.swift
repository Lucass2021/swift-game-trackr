import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct HomeViewModelTests {
    private static let overlapLatency: Duration = .milliseconds(50)

    private let repository = FakeGameRepository(latency: .zero)
    private let viewModel: HomeViewModel

    init() {
        viewModel = HomeViewModel(repository: repository)
    }

    @Test func loadShowsBothSections() async {
        await viewModel.loadIfNeeded()

        #expect(viewModel.newReleases.games.map(\.slug) == [HomeMockData.sampleGame.slug])
        #expect(viewModel.mostAnticipated.games.map(\.slug) == [HomeMockData.sampleGame.slug])
    }

    @Test func comingBackToHomeDoesNotReloadIt() async {
        await viewModel.loadIfNeeded()
        await viewModel.loadIfNeeded()

        #expect(await repository.fetchNewReleasesCount == 1)
        #expect(await repository.fetchMostAnticipatedCount == 1)
    }

    @Test func aFailedSectionShowsItsRetryAndTheOtherSectionStaysLoaded() async {
        await repository.setMostAnticipatedFailure(APIError.networkFailure)
        await viewModel.loadIfNeeded()

        #expect(viewModel.mostAnticipated.hasError)
        #expect(viewModel.mostAnticipated.games.isEmpty)
        #expect(!viewModel.newReleases.hasError)
        #expect(!viewModel.newReleases.games.isEmpty)
    }

    @Test func retryingASectionReloadsOnlyThatSection() async {
        await repository.setMostAnticipatedFailure(APIError.networkFailure)
        await viewModel.loadIfNeeded()

        await repository.setMostAnticipatedFailure(nil)
        await viewModel.onRetry(.mostAnticipated)

        #expect(!viewModel.mostAnticipated.games.isEmpty)
        #expect(await repository.fetchNewReleasesCount == 1)
        #expect(await repository.fetchMostAnticipatedCount == 2)
    }

    @Test func refreshKeepsTheGamesOnScreenUntilTheNewOnesArrive() async {
        let repository = FakeGameRepository(latency: Self.overlapLatency)
        let viewModel = HomeViewModel(repository: repository)
        await viewModel.loadIfNeeded()

        let refreshing = Task { await viewModel.refresh() }
        while await repository.fetchNewReleasesCount < 2 {
            await Task.yield()
        }

        #expect(viewModel.isRefreshing)
        #expect(!viewModel.newReleases.games.isEmpty)

        await refreshing.value

        #expect(!viewModel.isRefreshing)
    }

    @Test func aRefreshFailureKeepsTheGamesAndShowsAToast() async {
        await viewModel.loadIfNeeded()

        await repository.setNewReleasesFailure(APIError.networkFailure)
        await viewModel.refresh()

        #expect(!viewModel.newReleases.games.isEmpty)
        #expect(viewModel.toastMessage == "Couldn't refresh. Please try again.")
    }

    @Test func anEmptySectionWaitsForTheFirstAnswer() async {
        let repository = FakeGameRepository(homeGames: [], latency: Self.overlapLatency)
        let viewModel = HomeViewModel(repository: repository)

        let loading = Task { await viewModel.loadIfNeeded() }
        while await repository.fetchNewReleasesCount == 0 {
            await Task.yield()
        }

        #expect(viewModel.newReleases.isWaiting)

        await loading.value

        #expect(!viewModel.newReleases.isWaiting)
        #expect(!viewModel.newReleases.hasError)
        #expect(viewModel.newReleases.games.isEmpty)
    }

    @Test func leavingHomeDuringTheFirstLoadKeepsLoading() async {
        let repository = FakeGameRepository(latency: Self.overlapLatency)
        let viewModel = HomeViewModel(repository: repository)

        let loading = Task { await viewModel.loadIfNeeded() }
        while await repository.fetchNewReleasesCount == 0 {
            await Task.yield()
        }
        loading.cancel()
        await loading.value

        #expect(!viewModel.newReleases.hasError)
        #expect(!viewModel.newReleases.games.isEmpty)
        #expect(await repository.fetchNewReleasesCount == 1)
    }

    @Test func leavingHomeDuringARefreshShowsNoToast() async {
        let repository = FakeGameRepository(latency: Self.overlapLatency)
        let viewModel = HomeViewModel(repository: repository)
        await viewModel.loadIfNeeded()

        let refreshing = Task { await viewModel.refresh() }
        while await repository.fetchNewReleasesCount < 2 {
            await Task.yield()
        }
        refreshing.cancel()
        await refreshing.value

        #expect(viewModel.toastMessage == nil)
        #expect(!viewModel.newReleases.hasError)
    }

    @Test func aRefreshDuringTheFirstLoadReusesIt() async {
        let repository = FakeGameRepository(latency: Self.overlapLatency)
        let viewModel = HomeViewModel(repository: repository)

        let loading = Task { await viewModel.loadIfNeeded() }
        while await repository.fetchNewReleasesCount == 0 {
            await Task.yield()
        }
        await viewModel.refresh()
        await loading.value

        #expect(await repository.fetchNewReleasesCount == 1)
        #expect(await repository.fetchMostAnticipatedCount == 1)
        #expect(!viewModel.newReleases.games.isEmpty)
    }

    @Test func aRefreshFailureWithNoGamesOnScreenShowsNoToast() async {
        await repository.setNewReleasesFailure(APIError.networkFailure)
        await repository.setMostAnticipatedFailure(APIError.networkFailure)
        await viewModel.loadIfNeeded()

        await viewModel.refresh()

        #expect(viewModel.toastMessage == nil)
        #expect(viewModel.newReleases.hasError)
        #expect(viewModel.mostAnticipated.hasError)
    }
}
