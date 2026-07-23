import SwiftUI

enum ProfileMockData {
    static let profile = Profile(
        name: "Lucas Dias",
        username: "@lucasdias",
        bio: "Backlog eterno, platina ocasional. RPGs de turno e speedruns de fim de semana.",
        joinedAt: "Joined March 2024",
        avatarStart: .coverVioletStart,
        avatarEnd: .coverVioletEnd,
        stats: ProfileStats(totalGames: 142, hours: 1248, platinum: 21)
    )

    static let breakdown: [StatusCount] = [
        StatusCount(status: .playing, count: 8),
        StatusCount(status: .completed, count: 47),
        StatusCount(status: .backlog, count: 62),
        StatusCount(status: .platinum, count: 21),
        StatusCount(status: .abandoned, count: 4)
    ]

    static let favorites: [LibraryEntry] = [
        LibraryEntry(
            title: "Elden Ring",
            status: .platinum,
            rating: 5,
            hours: 210,
            coverStart: .coverEmeraldStart,
            coverEnd: .coverEmeraldEnd
        ),
        LibraryEntry(
            title: "Hollow Knight",
            status: .completed,
            rating: 5,
            hours: 64,
            coverStart: .coverIndigoStart,
            coverEnd: .coverIndigoEnd
        ),
        LibraryEntry(
            title: "Chrono Trigger",
            status: .platinum,
            rating: 5,
            hours: 38,
            coverStart: .coverCrimsonStart,
            coverEnd: .coverCrimsonEnd
        ),
        LibraryEntry(
            title: "Outer Wilds",
            status: .completed,
            rating: 5,
            hours: 27,
            coverStart: .coverCyanStart,
            coverEnd: .coverCyanEnd
        )
    ]

    static let currentlyPlaying: [LibraryEntry] = [
        LibraryEntry(
            title: "Cyberpunk 2077: Phantom Liberty",
            status: .playing,
            rating: 4,
            hours: 32,
            coverStart: .coverVioletStart,
            coverEnd: .coverVioletEnd
        ),
        LibraryEntry(
            title: "Final Fantasy VII Rebirth",
            status: .playing,
            rating: 5,
            hours: 61,
            coverStart: .coverAzureStart,
            coverEnd: .coverAzureEnd
        )
    ]

    static let activity: [ActivityEvent] = [
        ActivityEvent(kind: .platinum, gameTitle: "Uncharted: Legacy of Thieves", timeAgo: "2d"),
        ActivityEvent(kind: .rated, gameTitle: "Starfield", detail: "4 stars", timeAgo: "4d"),
        ActivityEvent(kind: .completed, gameTitle: "Hollow Knight", timeAgo: "1w"),
        ActivityEvent(kind: .started, gameTitle: "Final Fantasy VII Rebirth", timeAgo: "2w"),
        ActivityEvent(kind: .added, gameTitle: "Silksong", timeAgo: "3w")
    ]
}
