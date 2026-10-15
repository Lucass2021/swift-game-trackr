import SwiftUI
import Testing
@testable import GameTrackr

struct AchievementsSummaryTests {
    private static let completedGame = game(
        Achievement(title: "Platinum", detail: "All", tier: .platinum, unlockedAt: "Jul 2024"),
        Achievement(title: "Finish", detail: "End", tier: .gold, unlockedAt: "Jun 2024")
    )
    private static let startedGame = game(
        Achievement(title: "Start", detail: "Begin", tier: .bronze, unlockedAt: "May 2024"),
        Achievement(title: "Finish", detail: "End", tier: .gold, unlockedAt: nil)
    )

    @Test func summaryAggregatesEveryGame() {
        let summary = AchievementsSummary(games: [Self.completedGame, Self.startedGame])

        #expect(summary.unlockedCount == 3)
        #expect(summary.total == 4)
        #expect(summary.platinumCount == 1)
        #expect(summary.completedCount == 1)
        #expect(summary.gameCount == 2)
        #expect(summary.percent == 75)
    }

    @Test func summaryOfNoGamesIsEmpty() {
        let summary = AchievementsSummary(games: [])

        #expect(summary.total == 0)
        #expect(summary.percent == 0)
    }

    private static func game(_ achievements: Achievement...) -> GameAchievements {
        GameAchievements(
            title: "Game",
            platform: "PC",
            coverStart: .black,
            coverEnd: .black,
            achievements: achievements
        )
    }
}
