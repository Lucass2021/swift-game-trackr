import SwiftUI

enum AchievementsMockData {
    static let games: [GameAchievements] = [
        eldenRing,
        hollowKnight,
        chronoTrigger,
        outerWilds,
        phantomLiberty,
        rebirth
    ]

    private static let eldenRing = GameAchievements(
        title: "Elden Ring",
        platform: "PlayStation 5",
        coverStart: .coverEmeraldStart,
        coverEnd: .coverEmeraldEnd,
        achievements: [
            Achievement(
                title: "Elden Ring",
                detail: "Obtain all achievements",
                tier: .platinum,
                unlockedAt: "Jul 2024"
            ),
            Achievement(title: "Elden Lord", detail: "Complete the game", tier: .gold, unlockedAt: "Jun 2024"),
            Achievement(
                title: "Age of the Stars",
                detail: "Reach the Age of the Stars ending",
                tier: .gold,
                unlockedAt: "Jun 2024"
            ),
            Achievement(
                title: "Legendary Armaments",
                detail: "Collect all legendary armaments",
                tier: .gold,
                unlockedAt: "Jul 2024"
            ),
            Achievement(
                title: "Great Rune",
                detail: "Restore your first Great Rune",
                tier: .silver,
                unlockedAt: "Apr 2024"
            ),
            Achievement(
                title: "Godrick the Grafted",
                detail: "Defeat Godrick the Grafted",
                tier: .silver,
                unlockedAt: "Apr 2024"
            ),
            Achievement(
                title: "Malenia, Blade of Miquella",
                detail: "Defeat Malenia",
                tier: .silver,
                unlockedAt: "Jun 2024"
            ),
            Achievement(
                title: "Roundtable Hold",
                detail: "Arrive at Roundtable Hold",
                tier: .bronze,
                unlockedAt: "Mar 2024"
            )
        ]
    )

    private static let hollowKnight = GameAchievements(
        title: "Hollow Knight",
        platform: "Nintendo Switch",
        coverStart: .coverIndigoStart,
        coverEnd: .coverIndigoEnd,
        achievements: [
            Achievement(title: "Hollow Knight", detail: "Obtain all achievements", tier: .platinum, unlockedAt: nil),
            Achievement(title: "Dream No More", detail: "Achieve the final ending", tier: .gold, unlockedAt: nil),
            Achievement(title: "Pure Completion", detail: "Achieve 112% completion", tier: .gold, unlockedAt: nil),
            Achievement(title: "Blackegg", detail: "Complete the game", tier: .silver, unlockedAt: "Feb 2024"),
            Achievement(
                title: "Grimm Troupe",
                detail: "Complete the Grimm Troupe quest",
                tier: .silver,
                unlockedAt: "Feb 2024"
            ),
            Achievement(
                title: "Mantis Lords",
                detail: "Defeat the Mantis Lords",
                tier: .silver,
                unlockedAt: "Jan 2024"
            ),
            Achievement(
                title: "Mothwing Cloak",
                detail: "Obtain the Mothwing Cloak",
                tier: .bronze,
                unlockedAt: "Jan 2024"
            ),
            Achievement(title: "Soul Master", detail: "Defeat the Soul Master", tier: .bronze, unlockedAt: "Jan 2024")
        ]
    )

    private static let chronoTrigger = GameAchievements(
        title: "Chrono Trigger",
        platform: "PlayStation 5",
        coverStart: .coverCrimsonStart,
        coverEnd: .coverCrimsonEnd,
        achievements: [
            Achievement(
                title: "Chrono Trigger",
                detail: "Obtain all achievements",
                tier: .platinum,
                unlockedAt: "Dec 2023"
            ),
            Achievement(title: "Lavos Defeated", detail: "Defeat Lavos", tier: .gold, unlockedAt: "Dec 2023"),
            Achievement(title: "All Endings", detail: "See every ending", tier: .gold, unlockedAt: "Dec 2023"),
            Achievement(title: "The End of Time", detail: "Reach the End of Time", tier: .gold, unlockedAt: "Nov 2023"),
            Achievement(title: "New Game+", detail: "Start a New Game+", tier: .silver, unlockedAt: "Dec 2023"),
            Achievement(title: "First Jump", detail: "Use your first time gate", tier: .bronze, unlockedAt: "Nov 2023")
        ]
    )

    private static let outerWilds = GameAchievements(
        title: "Outer Wilds",
        platform: "PC",
        coverStart: .coverCyanStart,
        coverEnd: .coverCyanEnd,
        achievements: [
            Achievement(title: "Outer Wilds", detail: "Obtain all achievements", tier: .platinum, unlockedAt: nil),
            Achievement(title: "Quantum Moon", detail: "Land on the Quantum Moon", tier: .gold, unlockedAt: "Sep 2024"),
            Achievement(title: "The Search", detail: "Reach the Eye", tier: .gold, unlockedAt: nil, isSecret: true),
            Achievement(
                title: "Ash Twin Project",
                detail: "Reach the Ash Twin Project",
                tier: .silver,
                unlockedAt: "Sep 2024"
            ),
            Achievement(title: "Hotshot", detail: "Land on the Sun Station", tier: .silver, unlockedAt: "Aug 2024"),
            Achievement(
                title: "Escape Velocity",
                detail: "Leave the solar system",
                tier: .bronze,
                unlockedAt: "Aug 2024"
            )
        ]
    )

    private static let phantomLiberty = GameAchievements(
        title: "Cyberpunk 2077: Phantom Liberty",
        platform: "PlayStation 5",
        coverStart: .coverVioletStart,
        coverEnd: .coverVioletEnd,
        achievements: [
            Achievement(title: "Phantom Liberty", detail: "Obtain all achievements", tier: .platinum, unlockedAt: nil),
            Achievement(
                title: "The Killing Moon",
                detail: "Reach the Moon",
                tier: .gold,
                unlockedAt: nil,
                isSecret: true
            ),
            Achievement(
                title: "Spy vs Spy",
                detail: "Complete the Songbird questline",
                tier: .silver,
                unlockedAt: nil,
                isSecret: true
            ),
            Achievement(title: "Relic Master", detail: "Unlock every Relic perk", tier: .silver, unlockedAt: nil),
            Achievement(title: "Netrunner", detail: "Perform 25 quickhacks", tier: .bronze, unlockedAt: "Feb 2025"),
            Achievement(
                title: "Airdrop",
                detail: "Loot 10 airdrops in Dogtown",
                tier: .bronze,
                unlockedAt: "Jan 2025"
            ),
            Achievement(title: "Dogtown Local", detail: "Arrive in Dogtown", tier: .bronze, unlockedAt: "Jan 2025")
        ]
    )

    private static let rebirth = GameAchievements(
        title: "Final Fantasy VII Rebirth",
        platform: "PlayStation 5",
        coverStart: .coverAzureStart,
        coverEnd: .coverAzureEnd,
        achievements: [
            Achievement(title: "Rebirth", detail: "Obtain all achievements", tier: .platinum, unlockedAt: nil),
            Achievement(
                title: "The Promised Land",
                detail: "Finish the story",
                tier: .gold,
                unlockedAt: nil,
                isSecret: true
            ),
            Achievement(
                title: "Queen's Blood Champion",
                detail: "Win every Queen's Blood match",
                tier: .gold,
                unlockedAt: nil
            ),
            Achievement(
                title: "Master Chocobo Rider",
                detail: "Reach rank S in chocobo racing",
                tier: .silver,
                unlockedAt: nil
            ),
            Achievement(title: "Full Party", detail: "Recruit every party member", tier: .silver, unlockedAt: nil),
            Achievement(title: "Gold Saucer", detail: "Visit the Gold Saucer", tier: .silver, unlockedAt: "Mar 2025"),
            Achievement(title: "A New Journey", detail: "Complete Chapter 1", tier: .bronze, unlockedAt: "Feb 2025")
        ]
    )
}
