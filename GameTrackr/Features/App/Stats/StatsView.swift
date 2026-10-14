import SwiftUI

struct StatsView: View {
    var ownerName: String?
    var repository: StatsRepository = FakeStatsRepository()

    @Environment(\.dismiss) private var dismiss

    @State private var stats: UserStats?
    @State private var showAchievements = false

    var body: some View {
        VStack(spacing: 0) {
            StatsTopBar(
                title: ownerName == nil ? "Your Stats" : "Stats",
                subtitle: ownerName,
                onBack: { dismiss() },
                shareText: ownerName.map { "Check out \($0)'s gaming stats on GameTrackr!" }
                    ?? "Check out my gaming stats on GameTrackr!"
            )

            if let stats {
                content(stats)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showAchievements) {
            AchievementsView(ownerName: ownerName)
        }
        .task {
            guard stats == nil else { return }
            stats = try? await repository.fetchStats()
        }
    }

    private func content(_ stats: UserStats) -> some View {
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

                AchievementSpotlightCard(
                    spotlight: stats.spotlight,
                    onAction: { showAchievements = true }
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
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
