import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct MySetupViewModelTests {
    private static let editedTitle = "Edited"
    private static let newSetupId = 99
    private static let overlapLatency: Duration = .milliseconds(50)
    private static let userId = 7

    @Test func loadShowsTheSetupsFromTheRepository() async {
        let viewModel = MySetupViewModel(repository: FakeSetupRepository(latency: .zero))

        await viewModel.load()

        #expect(viewModel.setups == ProfileMockData.setups)
        #expect(!viewModel.isLoading)
    }

    @Test func loadFailureShowsTheErrorState() async {
        let viewModel = MySetupViewModel(repository: FakeSetupRepository(
            failure: APIError.networkFailure,
            latency: .zero
        ))

        await viewModel.load()

        #expect(viewModel.hasError)
        #expect(viewModel.setups.isEmpty)
    }

    @Test func switchingToAGuestDropsTheListAndALateLoadResultDoesNotBringItBack() async {
        let repository = FakeSetupRepository(latency: Self.overlapLatency)
        let viewModel = MySetupViewModel(repository: repository)

        let loading = Task { await viewModel.loadFor(Self.userId) }
        while await repository.fetchCount == 0 {
            await Task.yield()
        }
        await viewModel.loadFor(nil)
        await loading.value

        #expect(viewModel.setups.isEmpty)
        #expect(!viewModel.isLoading)
        #expect(!viewModel.hasError)
    }

    @Test func aNewRequestForTheSameUserKeepsTheListWithoutReloading() async {
        let repository = FakeSetupRepository(latency: .zero)
        let viewModel = MySetupViewModel(repository: repository)
        await viewModel.loadFor(Self.userId)

        await repository.setFailure(APIError.networkFailure)
        await viewModel.loadFor(Self.userId)

        #expect(viewModel.setups == ProfileMockData.setups)
        #expect(!viewModel.isLoading)
        #expect(!viewModel.hasError)
        #expect(await repository.fetchCount == 1)
    }

    @Test func aSecondLoadReplacesTheOneInFlightWithoutShowingAnError() async {
        let repository = FakeSetupRepository(failure: APIError.networkFailure, latency: Self.overlapLatency)
        let viewModel = MySetupViewModel(repository: repository)

        let first = await startLoading(viewModel, repository: repository)
        await repository.setFailure(nil)
        await viewModel.load()
        await first.value

        #expect(viewModel.setups == ProfileMockData.setups)
        #expect(!viewModel.hasError)
    }

    @Test func savedSetupsAreReplacedOrAppendedAndDeletedSetupsAreRemoved() async {
        let viewModel = MySetupViewModel(repository: FakeSetupRepository(latency: .zero))
        await viewModel.load()
        var edited = ProfileMockData.setups[0]
        edited.title = Self.editedTitle
        let created = SetupItem(id: Self.newSetupId, title: "New", description: "")

        viewModel.onSetupSaved(edited)
        viewModel.onSetupSaved(created)
        viewModel.onSetupDeleted(ProfileMockData.setups[1].id)

        #expect(viewModel.setups.map(\.id) == [
            ProfileMockData.setups[0].id,
            ProfileMockData.setups[2].id,
            Self.newSetupId
        ])
        #expect(viewModel.setups.first?.title == Self.editedTitle)
    }

    private func startLoading(
        _ viewModel: MySetupViewModel,
        repository: FakeSetupRepository
    ) async -> Task<Void, Never> {
        let task = Task { await viewModel.load() }
        while await repository.fetchCount == 0 {
            await Task.yield()
        }
        return task
    }
}
