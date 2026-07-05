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

enum NotificationFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case unread = "Unread"
    case mentions = "Mentions"

    var id: Self {
        self
    }
}

enum NotificationsMockData {
    static let items: [NotificationItem] = [
        NotificationItem(
            section: .new,
            leading: .avatar(start: .coverEmeraldStart, end: .coverEmeraldEnd, badge: .online),
            spans: [
                NotificationSpan(text: "@NeonShadow_X", style: .actor),
                NotificationSpan(text: " sent you a friend request", style: .text)
            ],
            timestamp: "2m",
            unread: true,
            isFriendRequest: true
        ),
        NotificationItem(
            section: .new,
            leading: .avatar(start: .coverAzureStart, end: .coverAzureEnd, badge: .online),
            spans: [
                NotificationSpan(text: "@QuestMaster", style: .actor),
                NotificationSpan(text: " replied to your post", style: .text)
            ],
            secondary: "Great points about the boss design…",
            secondaryIsQuote: true,
            timestamp: "1h",
            unread: true
        ),
        NotificationItem(
            section: .new,
            leading: .iconBox(icon: .like, tint: .appPrimary),
            spans: [
                NotificationSpan(text: "@RetroGamer", style: .actor),
                NotificationSpan(text: " liked your review of ", style: .text),
                NotificationSpan(text: "Elden Ring", style: .link)
            ],
            timestamp: "4h",
            unread: true,
            trailingDot: true
        ),
        NotificationItem(
            section: .today,
            leading: .thumbnail(start: .coverIndigoStart, end: .coverIndigoEnd),
            spans: [
                NotificationSpan(text: "New post in ", style: .text),
                NotificationSpan(text: "Neon Arcade // Elite", style: .link)
            ],
            secondary: "Tournament registration is now open…",
            timestamp: "6h"
        ),
        NotificationItem(
            section: .today,
            leading: .avatar(start: .coverVioletStart, end: .coverVioletEnd, badge: nil),
            spans: [
                NotificationSpan(text: "@cyber_queen", style: .actor),
                NotificationSpan(text: " mentioned you in a comment", style: .text)
            ],
            timestamp: "9h",
            isMention: true
        ),
        NotificationItem(
            section: .today,
            leading: .iconBox(icon: .medal, tint: .appPrimary),
            spans: [
                NotificationSpan(text: "You unlocked the ", style: .text),
                NotificationSpan(text: "Platinum Hunter", style: .highlight),
                NotificationSpan(text: " badge", style: .text)
            ],
            timestamp: "12h"
        ),
        NotificationItem(
            section: .thisWeek,
            leading: .avatar(start: .coverCrimsonStart, end: .coverCrimsonEnd, badge: .accepted),
            spans: [
                NotificationSpan(text: "@PixelWarrior", style: .actor),
                NotificationSpan(text: " accepted your friend request", style: .text)
            ],
            timestamp: "2d"
        ),
        NotificationItem(
            section: .thisWeek,
            leading: .iconBox(icon: .envelope, tint: .appTextSecondary),
            spans: [
                NotificationSpan(text: "@vortex_king", style: .actor),
                NotificationSpan(text: " sent you a message", style: .text)
            ],
            timestamp: "3d"
        )
    ]
}
