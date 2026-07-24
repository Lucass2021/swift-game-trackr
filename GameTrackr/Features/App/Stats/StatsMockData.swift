import SwiftUI

enum StatsMockData {
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
            StatBar(label: "RPG", value: "42 games", fraction: 1.0, tint: .appPrimary),
            StatBar(label: "Action", value: "38 games", fraction: 0.9, tint: .appSecondary),
            StatBar(label: "Strategy", value: "21 games", fraction: 0.5, tint: .appPrimary)
        ],
        platforms: [
            StatBar(label: "PlayStation 5", value: "60%", fraction: 0.6, tint: .appSecondary),
            StatBar(label: "PC Master Race", value: "25%", fraction: 0.25, tint: .appPrimary),
            StatBar(label: "Nintendo Switch", value: "15%", fraction: 0.15, tint: .appSecondary)
        ],
        yearsCompleted: [
            YearCount(year: "2021", count: 9, tint: .appSecondary.opacity(0.45)),
            YearCount(year: "2022", count: 14, tint: .appPrimary.opacity(0.5)),
            YearCount(year: "2023", count: 22, tint: .appSecondary),
            YearCount(year: "2024", count: 24, tint: .appPrimary)
        ],
        spotlight: AchievementSpotlight(
            title: "Achievement Master",
            message: "You've completed more games than 98% of people in your region this quarter. "
                + "Keep the streak alive!",
            actionTitle: "View achievements"
        )
    )
}
