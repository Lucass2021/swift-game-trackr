import SwiftUI

nonisolated enum NotificationsMockData {
    static let items: [NotificationItem] = [
        NotificationItem(
            id: 1,
            section: .new,
            leading: .avatar(cover: .emerald, badge: .online),
            spans: [
                NotificationSpan(text: "@NeonShadow_X", style: .actor),
                NotificationSpan(text: " sent you a friend request", style: .text)
            ],
            timestamp: "2m",
            unread: true,
            isFriendRequest: true
        ),
        NotificationItem(
            id: 2,
            section: .new,
            leading: .avatar(cover: .azure, badge: .online),
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
            id: 3,
            section: .new,
            leading: .iconBox(kind: .like),
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
            id: 4,
            section: .today,
            leading: .thumbnail(cover: .indigo),
            spans: [
                NotificationSpan(text: "New post in ", style: .text),
                NotificationSpan(text: "Neon Arcade // Elite", style: .link)
            ],
            secondary: "Tournament registration is now open…",
            timestamp: "6h"
        ),
        NotificationItem(
            id: 5,
            section: .today,
            leading: .avatar(cover: .violet, badge: nil),
            spans: [
                NotificationSpan(text: "@cyber_queen", style: .actor),
                NotificationSpan(text: " mentioned you in a comment", style: .text)
            ],
            timestamp: "9h",
            isMention: true
        ),
        NotificationItem(
            id: 6,
            section: .today,
            leading: .iconBox(kind: .achievement),
            spans: [
                NotificationSpan(text: "You unlocked the ", style: .text),
                NotificationSpan(text: "Platinum Hunter", style: .highlight),
                NotificationSpan(text: " badge", style: .text)
            ],
            timestamp: "12h"
        ),
        NotificationItem(
            id: 7,
            section: .thisWeek,
            leading: .avatar(cover: .crimson, badge: .accepted),
            spans: [
                NotificationSpan(text: "@PixelWarrior", style: .actor),
                NotificationSpan(text: " accepted your friend request", style: .text)
            ],
            timestamp: "2d"
        ),
        NotificationItem(
            id: 8,
            section: .thisWeek,
            leading: .iconBox(kind: .message),
            spans: [
                NotificationSpan(text: "@vortex_king", style: .actor),
                NotificationSpan(text: " sent you a message", style: .text)
            ],
            timestamp: "3d"
        )
    ]
}
