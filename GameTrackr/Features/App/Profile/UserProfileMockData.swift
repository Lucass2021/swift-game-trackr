import SwiftUI

struct UserProfile: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let username: String
    let avatarStart: Color
    let avatarEnd: Color
    var isFriend: Bool = false
}

extension UserProfile {
    init(handle: String, avatarStart: Color, avatarEnd: Color, isFriend: Bool = false) {
        let trimmed = handle.trimmingCharacters(in: .whitespaces)
        let hasAt = trimmed.hasPrefix("@")
        let display = hasAt ? String(trimmed.dropFirst()) : trimmed
        let username = hasAt
            ? trimmed
            : "@" + trimmed.lowercased().replacingOccurrences(of: " ", with: "")
        self.init(
            name: display,
            username: username,
            avatarStart: avatarStart,
            avatarEnd: avatarEnd,
            isFriend: isFriend
        )
    }
}

enum UserProfileMockData {
    static func profile(for user: UserProfile) -> Profile {
        Profile(
            name: user.name,
            username: user.username,
            bio: "Co-op enjoyer and lore hunter. Always down for a raid night or a slow-burn RPG.",
            joinedAt: "Joined January 2024",
            avatarStart: user.avatarStart,
            avatarEnd: user.avatarEnd,
            stats: ProfileStats(totalGames: 87, hours: 934, platinum: 12)
        )
    }

    static let breakdown: [StatusCount] = [
        StatusCount(status: .playing, count: 5),
        StatusCount(status: .completed, count: 31),
        StatusCount(status: .backlog, count: 39),
        StatusCount(status: .platinum, count: 12),
        StatusCount(status: .abandoned, count: 3)
    ]

    static let favorites: [LibraryEntry] = [
        LibraryEntry(
            title: "The Witcher 3",
            status: .platinum,
            rating: 5,
            hours: 168,
            coverStart: .coverPineStart,
            coverEnd: .coverPineEnd
        ),
        LibraryEntry(
            title: "Bloodborne",
            status: .completed,
            rating: 5,
            hours: 72,
            coverStart: .coverCrimsonStart,
            coverEnd: .coverCrimsonEnd
        ),
        LibraryEntry(
            title: "Celeste",
            status: .platinum,
            rating: 5,
            hours: 24,
            coverStart: .coverAzureStart,
            coverEnd: .coverAzureEnd
        ),
        LibraryEntry(
            title: "Disco Elysium",
            status: .completed,
            rating: 5,
            hours: 41,
            coverStart: .coverIndigoStart,
            coverEnd: .coverIndigoEnd
        )
    ]

    static let currentlyPlaying: [LibraryEntry] = [
        LibraryEntry(
            title: "Baldur's Gate 3",
            status: .playing,
            rating: 5,
            hours: 96,
            coverStart: .coverEmeraldStart,
            coverEnd: .coverEmeraldEnd
        ),
        LibraryEntry(
            title: "Helldivers 2",
            status: .playing,
            rating: 4,
            hours: 44,
            coverStart: .coverCyanStart,
            coverEnd: .coverCyanEnd
        )
    ]

    static let activity: [ActivityEvent] = [
        ActivityEvent(kind: .completed, gameTitle: "Baldur's Gate 3", timeAgo: "1d"),
        ActivityEvent(kind: .platinum, gameTitle: "Celeste", timeAgo: "5d"),
        ActivityEvent(kind: .rated, gameTitle: "Helldivers 2", detail: "4 stars", timeAgo: "1w"),
        ActivityEvent(kind: .started, gameTitle: "Baldur's Gate 3", timeAgo: "2w"),
        ActivityEvent(kind: .added, gameTitle: "Metaphor: ReFantazio", timeAgo: "3w")
    ]
}
