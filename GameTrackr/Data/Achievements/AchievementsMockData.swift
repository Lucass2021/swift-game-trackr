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
        id: 1,
        title: "Elden Ring",
        platform: "PlayStation 5",
        coverStart: .coverEmeraldStart,
        coverEnd: .coverEmeraldEnd,
        achievements: [
            Achievement(
                id: 101,
                title: "Elden Ring",
                detail: "Obtain all achievements",
                tier: .platinum,
                unlockedAt: "Jul 2024"
            ),
            Achievement(id: 102, title: "Elden Lord", detail: "Complete the game", tier: .gold, unlockedAt: "Jun 2024"),
            Achievement(
                id: 103,
                title: "Age of the Stars",
                detail: "Reach the Age of the Stars ending",
                tier: .gold,
                unlockedAt: "Jun 2024"
            ),
            Achievement(
                id: 104,
                title: "Legendary Armaments",
                detail: "Collect all legendary armaments",
                tier: .gold,
                unlockedAt: "Jul 2024"
            ),
            Achievement(
                id: 105,
                title: "Great Rune",
                detail: "Restore your first Great Rune",
                tier: .silver,
                unlockedAt: "Apr 2024"
            ),
            Achievement(
                id: 106,
                title: "Godrick the Grafted",
                detail: "Defeat Godrick the Grafted",
                tier: .silver,
                unlockedAt: "Apr 2024"
            ),
            Achievement(
                id: 107,
                title: "Malenia, Blade of Miquella",
                detail: "Defeat Malenia",
                tier: .silver,
                unlockedAt: "Jun 2024"
            ),
            Achievement(
                id: 108,
                title: "Roundtable Hold",
                detail: "Arrive at Roundtable Hold",
                tier: .bronze,
                unlockedAt: "Mar 2024"
            )
        ]
    )

    private static let hollowKnight = GameAchievements(
        id: 2,
        title: "Hollow Knight",
        platform: "Nintendo Switch",
        coverStart: .coverIndigoStart,
        coverEnd: .coverIndigoEnd,
        achievements: [
            Achievement(
                id: 201,
                title: "Hollow Knight",
                detail: "Obtain all achievements",
                tier: .platinum,
                unlockedAt: nil
            ),
            Achievement(
                id: 202,
                title: "Dream No More",
                detail: "Achieve the final ending",
                tier: .gold,
                unlockedAt: nil
            ),
            Achievement(
                id: 203,
                title: "Pure Completion",
                detail: "Achieve 112% completion",
                tier: .gold,
                unlockedAt: nil
            ),
            Achievement(id: 204, title: "Blackegg", detail: "Complete the game", tier: .silver, unlockedAt: "Feb 2024"),
            Achievement(
                id: 205,
                title: "Grimm Troupe",
                detail: "Complete the Grimm Troupe quest",
                tier: .silver,
                unlockedAt: "Feb 2024"
            ),
            Achievement(
                id: 206,
                title: "Mantis Lords",
                detail: "Defeat the Mantis Lords",
                tier: .silver,
                unlockedAt: "Jan 2024"
            ),
            Achievement(
                id: 207,
                title: "Mothwing Cloak",
                detail: "Obtain the Mothwing Cloak",
                tier: .bronze,
                unlockedAt: "Jan 2024"
            ),
            Achievement(
                id: 208,
                title: "Soul Master",
                detail: "Defeat the Soul Master",
                tier: .bronze,
                unlockedAt: "Jan 2024"
            )
        ]
    )

    private static let chronoTrigger = GameAchievements(
        id: 3,
        title: "Chrono Trigger",
        platform: "PlayStation 5",
        coverStart: .coverCrimsonStart,
        coverEnd: .coverCrimsonEnd,
        achievements: [
            Achievement(
                id: 301,
                title: "Chrono Trigger",
                detail: "Obtain all achievements",
                tier: .platinum,
                unlockedAt: "Dec 2023"
            ),
            Achievement(id: 302, title: "Lavos Defeated", detail: "Defeat Lavos", tier: .gold, unlockedAt: "Dec 2023"),
            Achievement(id: 303, title: "All Endings", detail: "See every ending", tier: .gold, unlockedAt: "Dec 2023"),
            Achievement(
                id: 304,
                title: "The End of Time",
                detail: "Reach the End of Time",
                tier: .gold,
                unlockedAt: "Nov 2023"
            ),
            Achievement(
                id: 305,
                title: "New Game+",
                detail: "Start a New Game+",
                tier: .silver,
                unlockedAt: "Dec 2023"
            ),
            Achievement(
                id: 306,
                title: "First Jump",
                detail: "Use your first time gate",
                tier: .bronze,
                unlockedAt: "Nov 2023"
            )
        ]
    )

    private static let outerWilds = GameAchievements(
        id: 4,
        title: "Outer Wilds",
        platform: "PC",
        coverStart: .coverCyanStart,
        coverEnd: .coverCyanEnd,
        achievements: [
            Achievement(
                id: 401,
                title: "Outer Wilds",
                detail: "Obtain all achievements",
                tier: .platinum,
                unlockedAt: nil
            ),
            Achievement(
                id: 402,
                title: "Quantum Moon",
                detail: "Land on the Quantum Moon",
                tier: .gold,
                unlockedAt: "Sep 2024"
            ),
            Achievement(
                id: 403,
                title: "The Search",
                detail: "Reach the Eye",
                tier: .gold,
                unlockedAt: nil,
                isSecret: true
            ),
            Achievement(
                id: 404,
                title: "Ash Twin Project",
                detail: "Reach the Ash Twin Project",
                tier: .silver,
                unlockedAt: "Sep 2024"
            ),
            Achievement(
                id: 405,
                title: "Hotshot",
                detail: "Land on the Sun Station",
                tier: .silver,
                unlockedAt: "Aug 2024"
            ),
            Achievement(
                id: 406,
                title: "Escape Velocity",
                detail: "Leave the solar system",
                tier: .bronze,
                unlockedAt: "Aug 2024"
            )
        ]
    )

    private static let phantomLiberty = GameAchievements(
        id: 5,
        title: "Cyberpunk 2077: Phantom Liberty",
        platform: "PlayStation 5",
        coverStart: .coverVioletStart,
        coverEnd: .coverVioletEnd,
        achievements: [
            Achievement(
                id: 501,
                title: "Phantom Liberty",
                detail: "Obtain all achievements",
                tier: .platinum,
                unlockedAt: nil
            ),
            Achievement(
                id: 502,
                title: "The Killing Moon",
                detail: "Reach the Moon",
                tier: .gold,
                unlockedAt: nil,
                isSecret: true
            ),
            Achievement(
                id: 503,
                title: "Spy vs Spy",
                detail: "Complete the Songbird questline",
                tier: .silver,
                unlockedAt: nil,
                isSecret: true
            ),
            Achievement(
                id: 504,
                title: "Relic Master",
                detail: "Unlock every Relic perk",
                tier: .silver,
                unlockedAt: nil
            ),
            Achievement(
                id: 505,
                title: "Netrunner",
                detail: "Perform 25 quickhacks",
                tier: .bronze,
                unlockedAt: "Feb 2025"
            ),
            Achievement(
                id: 506,
                title: "Airdrop",
                detail: "Loot 10 airdrops in Dogtown",
                tier: .bronze,
                unlockedAt: "Jan 2025"
            ),
            Achievement(
                id: 507,
                title: "Dogtown Local",
                detail: "Arrive in Dogtown",
                tier: .bronze,
                unlockedAt: "Jan 2025"
            )
        ]
    )

    private static let rebirth = GameAchievements(
        id: 6,
        title: "Final Fantasy VII Rebirth",
        platform: "PlayStation 5",
        coverStart: .coverAzureStart,
        coverEnd: .coverAzureEnd,
        achievements: [
            Achievement(id: 601, title: "Rebirth", detail: "Obtain all achievements", tier: .platinum, unlockedAt: nil),
            Achievement(
                id: 602,
                title: "The Promised Land",
                detail: "Finish the story",
                tier: .gold,
                unlockedAt: nil,
                isSecret: true
            ),
            Achievement(
                id: 603,
                title: "Queen's Blood Champion",
                detail: "Win every Queen's Blood match",
                tier: .gold,
                unlockedAt: nil
            ),
            Achievement(
                id: 604,
                title: "Master Chocobo Rider",
                detail: "Reach rank S in chocobo racing",
                tier: .silver,
                unlockedAt: nil
            ),
            Achievement(
                id: 605,
                title: "Full Party",
                detail: "Recruit every party member",
                tier: .silver,
                unlockedAt: nil
            ),
            Achievement(
                id: 606,
                title: "Gold Saucer",
                detail: "Visit the Gold Saucer",
                tier: .silver,
                unlockedAt: "Mar 2025"
            ),
            Achievement(
                id: 607,
                title: "A New Journey",
                detail: "Complete Chapter 1",
                tier: .bronze,
                unlockedAt: "Feb 2025"
            )
        ]
    )
}
