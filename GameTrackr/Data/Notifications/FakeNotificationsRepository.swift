struct FakeNotificationsRepository: NotificationsRepository {
    func fetchNotifications(page: Int, perPage: Int) async throws -> Page<NotificationItem> {
        try await Task.sleep(for: FakeLatency.responseDelay)
        return fakePage(items: NotificationsMockData.items, page: page, perPage: perPage)
    }

    func markAllAsRead() async throws {
        try await Task.sleep(for: FakeLatency.responseDelay)
    }

    func clearNotifications() async throws {
        try await Task.sleep(for: FakeLatency.responseDelay)
    }
}
