import SwiftUI

struct StatsView: View {
    var stats: UserStats = StatsMockData.stats
    var ownerName: String?
    var onAchievements: () -> Void = {}

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            StatsTopBar(
                title: ownerName == nil ? "Your Stats" : "Stats",
                subtitle: ownerName,
                onBack: { dismiss() }
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    ForEach(stats.highlights) { highlight in
                        StatHighlightCard(highlight: highlight)
                    }

                    StatsSectionCard(title: "By status", icon: .chart) {
                        StatusShareBar(shares: stats.statusShare)
                    }

                    StatsSectionCard(title: "Top genres", icon: .brand) {
                        StatBarList(bars: stats.genres)
                    }

                    StatsSectionCard(title: "By platform", icon: .devices) {
                        StatBarList(bars: stats.platforms)
                    }

                    StatsSectionCard(title: "By year completed", icon: .calendar) {
                        YearBarChart(years: stats.yearsCompleted)
                    }

                    AchievementSpotlightCard(spotlight: stats.spotlight, onAction: onAchievements)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview("Own stats") {
    NavigationStack {
        StatsView()
    }
    .preferredColorScheme(.dark)
}

#Preview("Other user") {
    NavigationStack {
        StatsView(ownerName: "Ana")
    }
    .preferredColorScheme(.dark)
}
