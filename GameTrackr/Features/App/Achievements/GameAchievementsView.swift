import SwiftUI

struct GameAchievementsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: GameAchievementsViewModel

    init(gameId: Int, repository: AchievementsRepository = FakeAchievementsRepository()) {
        _viewModel = State(initialValue: GameAchievementsViewModel(gameId: gameId, repository: repository))
    }

    var body: some View {
        VStack(spacing: 0) {
            StatsTopBar(
                title: "Achievements",
                subtitle: viewModel.game?.title,
                onBack: { dismiss() }
            )

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .task { await viewModel.loadIfNeeded() }
    }

    @ViewBuilder
    private var content: some View {
        if let game = viewModel.game {
            list(game)
        } else if viewModel.hasError {
            EmptyState(
                icon: .info,
                title: "Couldn't load achievements",
                message: "Check your connection and try again.",
                actionTitle: "Try again",
                onAction: { Task { await viewModel.load() } }
            )
            .frame(maxHeight: .infinity)
        } else {
            ProgressView()
                .tint(Color.appPrimary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func list(_ game: GameAchievements) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Spacing.lg) {
                GameAchievementsHeader(game: game)

                if !viewModel.unlockedAchievements.isEmpty {
                    StatsSectionCard(title: "Unlocked", icon: .success) {
                        achievementList(viewModel.unlockedAchievements)
                    }
                }

                if !viewModel.lockedAchievements.isEmpty {
                    StatsSectionCard(title: "Locked", icon: .eyeSlash) {
                        achievementList(viewModel.lockedAchievements)
                    }
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.sm)
            .padding(.bottom, Spacing.xxl)
        }
    }

    private func achievementList(_ achievements: [Achievement]) -> some View {
        VStack(spacing: Spacing.md) {
            ForEach(achievements) { achievement in
                AchievementRow(achievement: achievement)
            }
        }
    }
}

#Preview("Platinum") {
    NavigationStack {
        GameAchievementsView(gameId: AchievementsMockData.games[0].id)
    }
    .preferredColorScheme(.dark)
}

#Preview("In progress") {
    NavigationStack {
        GameAchievementsView(gameId: AchievementsMockData.games[4].id)
    }
    .preferredColorScheme(.dark)
}

#Preview("Error") {
    NavigationStack {
        GameAchievementsView(
            gameId: AchievementsMockData.games[0].id,
            repository: FakeAchievementsRepository(failure: APIError.networkFailure, latency: .zero)
        )
    }
    .preferredColorScheme(.dark)
}
