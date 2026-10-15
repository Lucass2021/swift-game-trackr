protocol NotificationsRepository: Sendable {
    func fetchNotifications(page: Int, perPage: Int) async throws -> Page<NotificationItem>
    func markAllAsRead() async throws
    func clearNotifications() async throws
}
