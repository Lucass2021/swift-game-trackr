import SwiftUI

struct StatsView: View {
    var ownerName: String?

    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: StatsViewModel
    @State private var showAchievements = false

    init(ownerName: String? = nil, repository: StatsRepository = FakeStatsRepository()) {
        self.ownerName = ownerName
        _viewModel = State(initialValue: StatsViewModel(repository: repository))
    }

    var body: some View {
        VStack(spacing: 0) {
            StatsTopBar(
                title: ownerName == nil ? "Your Stats" : "Stats",
                subtitle: ownerName,
                onBack: { dismiss() },
                shareText: ownerName.map { "Check out \($0)'s gaming stats on GameTrackr!" }
                    ?? "Check out my gaming stats on GameTrackr!"
            )

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showAchievements) {
            AchievementsView(ownerName: ownerName)
        }
        .task { await viewModel.loadIfNeeded() }
    }

    @ViewBuilder
    private var content: some View {
        if let stats = viewModel.stats {
            list(stats)
        } else if viewModel.hasError {
            EmptyState(
                icon: .info,
                title: "Couldn't load stats",
                message: "Check your connection and try again.",
                actionTitle: "Try again",
                onAction: { Task { await viewModel.load() } }
            )
            .frame(maxHeight: .infinity)
        } else {
            ProgressView()
                .tint(Color.appPrimary)
                .frame(maxHeight: .infinity)
        }
    }

    private func list(_ stats: UserStats) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Spacing.lg) {
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
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.sm)
            .padding(.bottom, Spacing.xxl)
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

#Preview("Error") {
    NavigationStack {
        StatsView(repository: FakeStatsRepository(failure: APIError.networkFailure, latency: .zero))
    }
    .preferredColorScheme(.dark)
}
