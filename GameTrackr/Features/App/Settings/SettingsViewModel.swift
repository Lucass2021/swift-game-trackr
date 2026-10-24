import Foundation

@MainActor
@Observable
final class SettingsViewModel {
    private(set) var notificationSettings: NotificationSettings?
    private(set) var isLoading = false
    private(set) var hasError = false
    private(set) var isDeleting = false
    private(set) var isDeleted = false
    var toastMessage: String?

    private let notificationSettingsRepository: NotificationSettingsRepository
    private let accountRepository: AccountRepository
    private var loadTask: Task<Void, Never>?
    private var toggleTasks: [NotificationSetting: Task<Void, Never>] = [:]

    init(notificationSettingsRepository: NotificationSettingsRepository, accountRepository: AccountRepository) {
        self.notificationSettingsRepository = notificationSettingsRepository
        self.accountRepository = accountRepository
    }

    func loadIfNeeded() async {
        guard notificationSettings == nil, !isLoading else { return }
        await load()
    }

    func load() async {
        loadTask?.cancel()
        isLoading = true
        hasError = false
        let task = Task {
            do {
                let settings = try await notificationSettingsRepository.fetchSettings()
                guard !Task.isCancelled else { return }
                notificationSettings = settings
            } catch {
                guard !Task.isCancelled else { return }
                hasError = true
            }
            isLoading = false
        }
        loadTask = task
        await task.value
    }

    func onNotificationToggle(_ setting: NotificationSetting, enabled: Bool) {
        guard notificationSettings != nil else { return }
        setLocally(setting, enabled: enabled)
        toggleTasks[setting]?.cancel()
        toggleTasks[setting] = Task {
            do {
                try await notificationSettingsRepository.updateSetting(setting, enabled: enabled)
            } catch {
                guard !Task.isCancelled else { return }
                setLocally(setting, enabled: !enabled)
                toastMessage = "Couldn't update notification settings. Please try again."
            }
        }
    }

    func deleteAccount() async {
        guard !isDeleting, !isDeleted else { return }
        isDeleting = true
        toastMessage = nil
        defer { isDeleting = false }

        do {
            try await accountRepository.deleteAccount()
            isDeleted = true
        } catch {
            toastMessage = error.userMessage()
        }
    }

    private func setLocally(_ setting: NotificationSetting, enabled: Bool) {
        notificationSettings = notificationSettings?.with(setting, enabled: enabled)
    }
}
