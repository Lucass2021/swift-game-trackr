import SwiftUI

nonisolated enum NotificationSection: String, CaseIterable {
    case new = "New"
    case today = "Today"
    case thisWeek = "This week"
}

nonisolated enum NotificationSpanStyle {
    case actor
    case text
    case link
    case highlight
}

nonisolated struct NotificationSpan: Identifiable {
    let id = UUID()
    let text: String
    let style: NotificationSpanStyle
}

nonisolated enum AvatarBadge {
    case online
    case accepted
}

nonisolated enum NotificationLeading {
    case avatar(start: Color, end: Color, badge: AvatarBadge?)
    case iconBox(icon: AppIcon, tint: Color)
    case thumbnail(start: Color, end: Color)
}

nonisolated struct NotificationItem: Identifiable {
    let id: Int
    let section: NotificationSection
    let leading: NotificationLeading
    let spans: [NotificationSpan]
    var secondary: String?
    var secondaryIsQuote = false
    let timestamp: String
    var unread = false
    var trailingDot = false
    var isMention = false
    var isFriendRequest = false
}
