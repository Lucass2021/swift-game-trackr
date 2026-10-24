import Foundation

actor FakeNotificationSettingsRepository: NotificationSettingsRepository {
    private(set) var settings: NotificationSettings
    private(set) var fetchCount = 0
    private(set) var updateCount = 0
    private var failure: Error?
    private let latency: Duration

    init(
        settings: NotificationSettings = NotificationSettings(),
        failure: Error? = nil,
        latency: Duration = FakeLatency.responseDelay
    ) {
        self.settings = settings
        self.failure = failure
        self.latency = latency
    }

    func fetchSettings() async throws -> NotificationSettings {
        fetchCount += 1
        try await respond()
        return settings
    }

    func updateSetting(_ setting: NotificationSetting, enabled: Bool) async throws {
        updateCount += 1
        try await respond()
        settings = settings.with(setting, enabled: enabled)
    }

    func setFailure(_ error: Error?) {
        failure = error
    }

    private func respond() async throws {
        let failure = failure
        try await Task.sleep(for: latency)
        if let failure { throw failure }
    }
}
