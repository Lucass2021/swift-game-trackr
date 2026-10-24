import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct SettingsViewModelTests {
    private static let stored = NotificationSettings(friendRequests: false)
    private static let overlapLatency = Duration.milliseconds(50)
    private static let waitTimeout = Duration.seconds(2)

    private let notificationSettings = FakeNotificationSettingsRepository(settings: Self.stored, latency: .zero)
    private let accounts = FakeAccountRepository(latency: .zero)

    private func viewModel(_ repository: FakeNotificationSettingsRepository? = nil) -> SettingsViewModel {
        SettingsViewModel(
            notificationSettingsRepository: repository ?? notificationSettings,
            accountRepository: accounts
        )
    }

    private func loadedViewModel(_ repository: FakeNotificationSettingsRepository? = nil) async -> SettingsViewModel {
        let viewModel = viewModel(repository)
        await viewModel.loadIfNeeded()
        return viewModel
    }

    @Test func loadShowsTheStoredNotificationSettings() async {
        let viewModel = await loadedViewModel()

        #expect(viewModel.notificationSettings == Self.stored)
        #expect(!viewModel.isLoading)
    }

    @Test func aToggleIsSavedAndSurvivesReopeningTheScreen() async {
        let viewModel = await loadedViewModel()

        viewModel.onNotificationToggle(.push, enabled: false)
        #expect(viewModel.notificationSettings?.push == false)
        await waitUntil { await notificationSettings.updateCount == 1 }
        let saved = await notificationSettings.settings
        #expect(!saved.push)

        let reopened = await loadedViewModel()
        #expect(reopened.notificationSettings?.push == false)
    }

    @Test func aFailedToggleRevertsOnlyThatSettingAndShowsAToast() async {
        let viewModel = await loadedViewModel()

        await notificationSettings.setFailure(APIError.networkFailure)
        viewModel.onNotificationToggle(.communityReplies, enabled: false)
        await waitUntil { viewModel.toastMessage != nil }

        #expect(viewModel.notificationSettings == Self.stored)
        #expect(viewModel.toastMessage == "Couldn't update notification settings. Please try again.")
    }

    @Test func aQuickSecondToggleSupersedesTheFirstWithoutAnError() async {
        let repository = FakeNotificationSettingsRepository(settings: Self.stored, latency: Self.overlapLatency)
        let viewModel = await loadedViewModel(repository)

        await repository.setFailure(APIError.networkFailure)
        viewModel.onNotificationToggle(.push, enabled: false)
        await waitUntil { await repository.updateCount == 1 }
        await repository.setFailure(nil)
        viewModel.onNotificationToggle(.push, enabled: true)
        await waitUntil { await repository.updateCount == 2 }
        try? await Task.sleep(for: Self.overlapLatency * 2)

        #expect(viewModel.notificationSettings?.push == true)
        #expect(viewModel.toastMessage == nil)
    }

    @Test func aLoadFailureShowsAnErrorAndRetryLoadsTheSettings() async {
        await notificationSettings.setFailure(APIError.networkFailure)
        let viewModel = await loadedViewModel()
        #expect(viewModel.hasError)

        await notificationSettings.setFailure(nil)
        await viewModel.load()

        #expect(!viewModel.hasError)
        #expect(viewModel.notificationSettings == Self.stored)
    }

    @Test func deleteAccountSendsOneRequestAndThenSignsOut() async {
        let viewModel = viewModel()

        async let first: Void = viewModel.deleteAccount()
        async let second: Void = viewModel.deleteAccount()
        _ = await (first, second)
        await viewModel.deleteAccount()

        #expect(viewModel.isDeleted)
        #expect(await accounts.deleteCount == 1)
    }

    @Test func aDeleteFailureShowsAToastAndKeepsTheUserSignedIn() async {
        await accounts.setFailure(APIError.networkFailure)
        let viewModel = viewModel()

        await viewModel.deleteAccount()

        #expect(!viewModel.isDeleted)
        #expect(!viewModel.isDeleting)
        #expect(viewModel.toastMessage == APIError.networkFailure.userMessage())
    }

    private func waitUntil(_ condition: () async -> Bool) async {
        let deadline = ContinuousClock.now + Self.waitTimeout
        while await !condition(), ContinuousClock.now < deadline {
            await Task.yield()
        }
    }
}
