import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct EditProfileViewModelTests {
    private static let usernameTaken = "The username has already been taken."

    private let repository = FakeProfileRepository(latency: .zero)
    private let authStore = AuthStore(tokenStore: FakeTokenStore())

    private func viewModel() -> EditProfileViewModel {
        EditProfileViewModel(profile: ProfileMockData.profile, repository: repository)
    }

    @Test func startsFromTheProfileAndLoadsTheColors() async {
        let viewModel = viewModel()
        await viewModel.loadColorsIfNeeded()

        #expect(viewModel.username == "lucasdias")
        #expect(viewModel.colors.map(\.hex) == ProfileMockData.colors.map(\.hex))
        #expect(!viewModel.hasChanges)
    }

    @Test func colorsFailureShowsRetryAndRetryLoadsThem() async {
        await repository.setFailure(APIError.networkFailure)
        let viewModel = viewModel()
        await viewModel.loadColorsIfNeeded()
        #expect(viewModel.colorsFailed)

        await repository.setFailure(nil)
        await viewModel.loadColors()

        #expect(!viewModel.colorsFailed)
        #expect(viewModel.colors.map(\.hex) == ProfileMockData.colors.map(\.hex))
        #expect(await repository.fetchColorsCount == 2)
    }

    @Test func errorsShowOnlyAfterTheFirstSaveAttempt() async {
        let viewModel = viewModel()
        viewModel.onNameChange("Al")
        #expect(viewModel.nameError == nil)

        let saved = await viewModel.save(authStore: authStore)

        #expect(saved == nil)
        #expect(viewModel.nameError == "At least 3 characters")
        #expect(await repository.updateCount == 0)
    }

    @Test func saveSendsTrimmedValuesUpdatesTheSessionAndReturnsTheProfile() async {
        let viewModel = viewModel()
        viewModel.onNameChange("  Lucas  ")
        viewModel.onUsernameChange(" LucasD ")
        viewModel.onVisibilityChange(.privateProfile)

        let saved = await viewModel.save(authStore: authStore)

        #expect(saved?.name == "Lucas")
        #expect(saved?.username == "@lucasd")
        #expect(saved?.visibility == .privateProfile)
        #expect(await repository.user.username == "lucasd")
        #expect(authStore.currentUser?.username == "lucasd")
    }

    @Test func saveFailureKeepsTheEditsAndShowsTheServerMessage() async {
        let viewModel = viewModel()
        viewModel.onNameChange("Lucas")
        await repository.setFailure(APIError.validation(Self.usernameTaken))

        let saved = await viewModel.save(authStore: authStore)

        #expect(saved == nil)
        #expect(viewModel.toastMessage == Self.usernameTaken)
        #expect(viewModel.name == "Lucas")
        #expect(!viewModel.isSaving)
    }

    @Test func doubleTapOnSaveSendsOneRequest() async {
        let viewModel = viewModel()

        async let first = viewModel.save(authStore: authStore)
        async let second = viewModel.save(authStore: authStore)
        _ = await (first, second)

        #expect(await repository.updateCount == 1)
    }

    @Test func saveAfterASuccessfulSaveSendsNoRequest() async {
        let viewModel = viewModel()
        _ = await viewModel.save(authStore: authStore)

        let second = await viewModel.save(authStore: authStore)

        #expect(second == nil)
        #expect(await repository.updateCount == 1)
    }

    @Test func hasChangesComparesTrimmedValuesWithTheProfile() {
        let viewModel = viewModel()
        viewModel.onNameChange("\(ProfileMockData.profile.name)  ")
        #expect(!viewModel.hasChanges)

        viewModel.onAvatarColorChange(ProfileMockData.colors[2].hex)
        #expect(viewModel.hasChanges)
    }
}
