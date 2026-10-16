import SwiftUI

private enum Constants {
    static let loadMoreThreshold = 2
}

struct AchievementsList: View {
    let games: [GameAchievements]
    let summary: AchievementsSummary?
    let canLoadMore: Bool
    let isLoadingMore: Bool
    let loadMoreFailed: Bool
    let onLoadMore: () -> Void
    let onGameSelect: (Int) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: Spacing.sm) {
                if let summary {
                    AchievementsSummaryCard(summary: summary)
                        .padding(.bottom, Spacing.xxs)
                }

                ForEach(Array(games.enumerated()), id: \.element.id) { index, game in
                    Button { onGameSelect(game.id) } label: {
                        GameAchievementsRow(game: game)
                    }
                    .buttonStyle(PressableButtonStyle())
                    .onAppear {
                        if canLoadMore, index >= games.count - Constants.loadMoreThreshold {
                            onLoadMore()
                        }
                    }
                }

                if isLoadingMore {
                    LoadingMoreIndicator()
                }

                if loadMoreFailed {
                    LoadMoreErrorRow(onRetry: onLoadMore)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.sm)
            .padding(.bottom, Spacing.xxl)
        }
    }
}

#Preview {
    AchievementsList(
        games: AchievementsMockData.games,
        summary: nil,
        canLoadMore: false,
        isLoadingMore: false,
        loadMoreFailed: false,
        onLoadMore: {},
        onGameSelect: { _ in }
    )
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
