import SwiftUI

nonisolated enum StatsMockData {
    static let stats = UserStats(
        highlights: [
            StatHighlight(label: "Games", value: "142", caption: "+12 this month"),
            StatHighlight(label: "Hours", value: "3,420", caption: "~24h / week avg"),
            StatHighlight(label: "Platinum %", value: "15%", caption: "Top 5% of users")
        ],
        statusShare: [
            StatusShare(status: .completed, percent: 45),
            StatusShare(status: .playing, percent: 30),
            StatusShare(status: .backlog, percent: 25)
        ],
        genres: [
            StatBar(label: "RPG", value: "42 games", fraction: 1.0, accent: .primary),
            StatBar(label: "Action", value: "38 games", fraction: 0.9, accent: .secondary),
            StatBar(label: "Strategy", value: "21 games", fraction: 0.5, accent: .primary)
        ],
        platforms: [
            StatBar(label: "PlayStation 5", value: "60%", fraction: 0.6, accent: .secondary),
            StatBar(label: "PC Master Race", value: "25%", fraction: 0.25, accent: .primary),
            StatBar(label: "Nintendo Switch", value: "15%", fraction: 0.15, accent: .secondary)
        ],
        yearsCompleted: [
            YearCount(year: "2021", count: 9, accent: .secondaryMuted),
            YearCount(year: "2022", count: 14, accent: .primaryMuted),
            YearCount(year: "2023", count: 22, accent: .secondary),
            YearCount(year: "2024", count: 24, accent: .primary)
        ],
        spotlight: AchievementSpotlight(
            title: "Achievement Master",
            message: "You've completed more games than 98% of people in your region this quarter. "
                + "Keep the streak alive!",
            actionTitle: "View achievements"
        )
    )
}
