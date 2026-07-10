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
        discussions: [
            GameDiscussion(
                author: "Kaelen_Vox",
                timeAgo: "2h ago",
                title: "Best builds for early game?",
                preview: "Just started my playthrough on PS5. Should I focus on the tech tree or go full stealth?",
                comments: 24,
                likes: 142,
                avatarStart: .coverPineStart,
                avatarEnd: .coverPineEnd
            ),
            GameDiscussion(
                author: "CyberDrifter_99",
                timeAgo: "5h ago",
                title: "The level design is insane!",
                preview: "The verticality in the Upper District is unlike anything I've seen in an open world.",
                comments: 86,
                likes: 856,
                avatarStart: .coverAzureStart,
                avatarEnd: .coverAzureEnd
            )
        ],
        specs: [
            GameSpec(label: "Developer", value: "Void Interactive"),
            GameSpec(label: "Publisher", value: "Nova Games"),
            GameSpec(label: "Storage", value: "85.4 GB"),
            GameSpec(label: "Language", value: "English, +12 more")
        ],
        systemRequirements: [
            SystemRequirementTier(
                name: "Minimum",
                items: [
                    GameSpec(label: "OS", value: "Windows 10 64-bit"),
                    GameSpec(label: "CPU", value: "Intel Core i5-8400"),
                    GameSpec(label: "GPU", value: "NVIDIA GTX 1060 6GB"),
                    GameSpec(label: "Memory", value: "12 GB RAM")
                ]
            ),
            SystemRequirementTier(
                name: "Recommended",
                items: [
                    GameSpec(label: "OS", value: "Windows 11 64-bit"),
                    GameSpec(label: "CPU", value: "Intel Core i7-12700K"),
                    GameSpec(label: "GPU", value: "NVIDIA RTX 3070 8GB"),
                    GameSpec(label: "Memory", value: "16 GB RAM")
                ]
            )
        ]
    )
}
