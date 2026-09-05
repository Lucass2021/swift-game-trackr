import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct HomeViewModelTests {
    @Test func loadsBothSlidersFromTheInjectedService() async {
        let service = FakeGameService(slider: [TestData.game(id: 1, name: "Hades II")])
        let viewModel = HomeViewModel(service: service)

        await viewModel.loadAll()

        #expect(viewModel.newReleases.games.map(\.name) == ["Hades II"])
        #expect(viewModel.mostAnticipated.games.map(\.name) == ["Hades II"])
        #expect(!viewModel.newReleases.isLoading)
        #expect(viewModel.newReleases.hasLoaded)
    }

    @Test func flagsFailureWithoutLosingTheSettledState() async {
        let service = FakeGameService(failure: .networkFailure)
        let viewModel = HomeViewModel(service: service)

        await viewModel.loadAll()

        #expect(viewModel.newReleases.failed)
        #expect(viewModel.newReleases.hasLoaded)
        #expect(viewModel.newReleases.isEmptyAndSettled)
    }

    @Test func skipsTheRefetchUnlessForced() async {
        let service = FakeGameService(slider: [TestData.game(id: 1, name: "Hades II")])
        let viewModel = HomeViewModel(service: service)

        await viewModel.loadAll()
        await viewModel.loadAll()

        #expect(service.recorder.count("slider") == 2)

        await viewModel.loadAll(force: true)

        #expect(service.recorder.count("slider") == 4)
    }

    @Test func retriesAfterAFailedLoadWithoutForcing() async {
        let viewModel = HomeViewModel(service: FakeGameService(failure: .networkFailure))

        await viewModel.loadAll()
        await viewModel.loadAll()

        #expect(viewModel.newReleases.failed)
    }
}
