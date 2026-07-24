import SwiftUI

struct StatHighlight: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let caption: String
}

struct StatusShare: Identifiable {
    var id: LibraryStatus {
        status
    }

    let status: LibraryStatus
    let percent: Int
}

struct StatBar: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let fraction: Double
    let tint: Color
}

struct YearCount: Identifiable {
    let id = UUID()
    let year: String
    let count: Int
    let tint: Color
}

struct AchievementSpotlight {
    let title: String
    let message: String
    let actionTitle: String
}

struct UserStats {
    let highlights: [StatHighlight]
    let statusShare: [StatusShare]
    let genres: [StatBar]
    let platforms: [StatBar]
    let yearsCompleted: [YearCount]
    let spotlight: AchievementSpotlight
}
