nonisolated enum NotificationFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case unread = "Unread"
    case mentions = "Mentions"

    var id: Self {
        self
    }
}
