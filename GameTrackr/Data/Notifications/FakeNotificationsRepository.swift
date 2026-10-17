actor FakeNotificationsRepository: NotificationsRepository {
    private(set) var fetchCount = 0
    private var items: [NotificationItem]
    private var failure: Error?
    private let latency: Duration

    init(
        items: [NotificationItem] = NotificationsMockData.items,
        failure: Error? = nil,
        latency: Duration = FakeLatency.responseDelay
    ) {
        self.items = items
        self.failure = failure
        self.latency = latency
    }

    var storedItems: [NotificationItem] {
        items
    }

    func fetchNotifications(filter: NotificationFilter, page: Int, perPage: Int) async throws
        -> Page<NotificationItem>
    {
        fetchCount += 1
        try await respond()
        return fakePage(items: items.filter { matches($0, filter) }, page: page, perPage: perPage)
    }

    func markAllAsRead() async throws {
        try await respond()
        for index in items.indices {
            items[index].unread = false
        }
    }

    func clearNotifications() async throws {
        try await respond()
        items.removeAll()
    }

    func respondToFriendRequest(id: Int, accept _: Bool) async throws {
        try await respond()
        guard let index = items.firstIndex(where: { $0.id == id && $0.isFriendRequest }) else {
            throw APIError.notFound
        }
        items.remove(at: index)
    }

    func setFailure(_ error: Error?) {
        failure = error
    }

    private func matches(_ item: NotificationItem, _ filter: NotificationFilter) -> Bool {
        switch filter {
        case .all: true
        case .unread: item.unread
        case .mentions: item.isMention
        }
    }

    private func respond() async throws {
        let error = failure
        try await Task.sleep(for: latency)
        if let error { throw error }
    }
}
