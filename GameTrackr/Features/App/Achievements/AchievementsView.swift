import SwiftUI

struct AchievementsView: View {
    var ownerName: String?

    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: AchievementsViewModel
    @State private var selectedGameId: Int?
    private let repository: AchievementsRepository

    init(ownerName: String? = nil, repository: AchievementsRepository = FakeAchievementsRepository()) {
        self.ownerName = ownerName
        self.repository = repository
        _viewModel = State(initialValue: AchievementsViewModel(repository: repository))
    }

    var body: some View {
        VStack(spacing: 0) {
            StatsTopBar(
                title: "Achievements",
                subtitle: ownerName,
                onBack: { dismiss() }
            )

            AchievementFilterChips(selection: viewModel.filter) { filter in
                Task { await viewModel.onFilterChange(filter) }
            }
            .padding(.bottom, Spacing.xxs)

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(item: $selectedGameId) { gameId in
            GameAchievementsView(gameId: gameId, repository: repository)
        }
        .task { await viewModel.loadIfNeeded() }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.hasError {
            EmptyState(
                icon: .info,
                title: "Couldn't load achievements",
                message: "Check your connection and try again.",
                actionTitle: "Try again",
                onAction: { Task { await viewModel.load() } }
            )
            .frame(maxHeight: .infinity)
        } else if viewModel.currentPage == 0 {
            ProgressView()
                .tint(Color.appPrimary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.games.isEmpty {
            EmptyState(
                icon: .trophy,
                title: "Nothing here yet",
                message: "Achievements from the games in your library show up here as you unlock them."
            )
            .frame(maxHeight: .infinity)
        } else {
            AchievementsList(
                games: viewModel.games,
                summary: viewModel.showsSummary ? viewModel.summary : nil,
                canLoadMore: viewModel.canLoadMore,
                isLoadingMore: viewModel.isLoadingMore,
                loadMoreFailed: viewModel.loadMoreFailed,
                onLoadMore: { Task { await viewModel.loadMore() } },
                onGameSelect: { selectedGameId = $0 }
            )
        }
    }
}

#Preview("Own") {
    NavigationStack {
        AchievementsView()
    }
    .preferredColorScheme(.dark)
}

#Preview("Other user") {
    NavigationStack {
        AchievementsView(ownerName: "Ana")
    }
    .preferredColorScheme(.dark)
}

#Preview("Error") {
    NavigationStack {
        AchievementsView(repository: FakeAchievementsRepository(failure: APIError.networkFailure, latency: .zero))
    }
    .preferredColorScheme(.dark)
}
