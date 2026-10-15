import SwiftUI

enum NotificationSection: String, CaseIterable {
    case new = "New"
    case today = "Today"
    case thisWeek = "This week"
}

enum NotificationSpanStyle {
    case actor
    case text
    case link
    case highlight
}

struct NotificationSpan: Identifiable {
    let id = UUID()
    let text: String
    let style: NotificationSpanStyle
}

enum AvatarBadge {
    case online
    case accepted
}

enum NotificationLeading {
    case avatar(start: Color, end: Color, badge: AvatarBadge?)
    case iconBox(icon: AppIcon, tint: Color)
    case thumbnail(start: Color, end: Color)
}

struct NotificationItem: Identifiable {
    let id = UUID()
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
