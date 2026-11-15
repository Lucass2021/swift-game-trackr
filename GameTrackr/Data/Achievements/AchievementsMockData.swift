import Foundation

nonisolated enum AchievementsMockData {
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
        cover: .emerald,
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
        cover: .indigo,
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
        cover: .crimson,
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
}
