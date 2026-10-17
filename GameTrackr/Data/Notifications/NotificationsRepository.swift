protocol NotificationsRepository: Sendable {
    func fetchNotifications(filter: NotificationFilter, page: Int, perPage: Int) async throws
        -> Page<NotificationItem>
    func markAllAsRead() async throws
    func clearNotifications() async throws
    func respondToFriendRequest(id: Int, accept: Bool) async throws
}
