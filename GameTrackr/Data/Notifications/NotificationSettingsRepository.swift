protocol NotificationSettingsRepository: Sendable {
    func fetchSettings() async throws -> NotificationSettings
    func updateSetting(_ setting: NotificationSetting, enabled: Bool) async throws
}
