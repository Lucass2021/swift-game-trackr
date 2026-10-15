import SwiftUI
import Testing
@testable import GameTrackr

struct AchievementsSummaryTests {
    private static let completedGame = game(
        id: 1,
        Achievement(id: 1, title: "Platinum", detail: "All", tier: .platinum, unlockedAt: "Jul 2024"),
        Achievement(id: 2, title: "Finish", detail: "End", tier: .gold, unlockedAt: "Jun 2024")
    )
    private static let startedGame = game(
        id: 2,
        Achievement(id: 3, title: "Start", detail: "Begin", tier: .bronze, unlockedAt: "May 2024"),
        Achievement(id: 4, title: "Finish", detail: "End", tier: .gold, unlockedAt: nil)
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

    private static func game(id: Int, _ achievements: Achievement...) -> GameAchievements {
        GameAchievements(
            id: id,
            title: "Game \(id)",
            platform: "PC",
            coverStart: .black,
            coverEnd: .black,
            achievements: achievements
        )
    }
}
