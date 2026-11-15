import Foundation

nonisolated extension AchievementsMockData {
    static let outerWilds = GameAchievements(
        id: 4,
        title: "Outer Wilds",
        platform: "PC",
        cover: .cyan,
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

    static let phantomLiberty = GameAchievements(
        id: 5,
        title: "Cyberpunk 2077: Phantom Liberty",
        platform: "PlayStation 5",
        cover: .violet,
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

    static let rebirth = GameAchievements(
        id: 6,
        title: "Final Fantasy VII Rebirth",
        platform: "PlayStation 5",
        cover: .azure,
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
