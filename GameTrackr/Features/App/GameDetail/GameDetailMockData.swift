import SwiftUI

enum GameDetailMockData {
    static let game = GameDetail(
        title: "Neon Ascent: Revival",
        year: "2024",
        rating: 4.8,
        platforms: ["PS5", "PC"],
        genres: ["Action RPG", "Open World", "Cyberpunk"],
        coverStart: .coverVioletStart,
        coverEnd: .coverVioletEnd,
        heroURL: nil,
        screenshots: [
            GameScreenshot(start: .coverIndigoStart, end: .coverIndigoEnd),
            GameScreenshot(start: .coverCyanStart, end: .coverCyanEnd),
            GameScreenshot(start: .coverCrimsonStart, end: .coverCrimsonEnd),
            GameScreenshot(start: .coverEmeraldStart, end: .coverEmeraldEnd)
        ],
        about: """
        Neon Ascent: Revival is the definitive next-gen cyberpunk experience. Set in \
        the sprawling vertical megacity of Aethelgard, players take on the role of a \
        rogue netrunner untangling a conspiracy that reaches from the neon-drenched \
        undercity to the corporate spires above.
        """,
        specs: [
            GameSpec(label: "Developer", value: "Void Interactive"),
            GameSpec(label: "Publisher", value: "Nova Games"),
            GameSpec(label: "Released", value: "Mar 14, 2024"),
            GameSpec(label: "Modes", value: "Single player, Co-operative")
        ]
    )
}
