import SwiftUI

struct LibraryView: View {
    @Bindable var viewModel: LibraryViewModel
    var onBrowseGames: () -> Void = {}
    var onGameSelect: (String) -> Void = { _ in }

    @Environment(AuthStore.self) private var authStore

    var body: some View {
        if authStore.isGuest {
            guestState
        } else {
            VStack(spacing: 0) {
                if let stats = viewModel.stats, !viewModel.isLibraryEmpty {
                    LibraryStatsBar(stats: stats)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.sm)
                        .padding(.bottom, Spacing.md)
                }

                LibraryFilterChips(selection: viewModel.filter) { status in
                    Task { await viewModel.onFilterChange(status) }
                }
                .padding(.top, viewModel.stats == nil || viewModel.isLibraryEmpty ? Spacing.sm : 0)
                .padding(.bottom, Spacing.sm)

                content
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground)
            .toast(message: $viewModel.errorMessage)
        }
    }

    private var guestState: some View {
        EmptyState(
            icon: .brand,
            title: "Library needs an account",
            message: "Create an account to start tracking your games, building your collection, "
                + "and logging your progress.",
            actionTitle: "Create an account",
            onAction: { authStore.logout() }
        )
        .frame(maxHeight: .infinity)
        .background(Color.appBackground)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.hasError {
            EmptyState(
                icon: .info,
                title: "Couldn't load your library",
                message: "Check your connection and try again.",
                actionTitle: "Try again",
                onAction: { Task { await viewModel.load() } }
            )
            .frame(maxHeight: .infinity)
        } else if viewModel.currentPage == 0 {
            ProgressView()
                .tint(Color.appPrimary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.isLibraryEmpty {
            EmptyState(
                icon: .brand,
                title: "Your library is empty",
                message: "Find games to start tracking your journey and building your ultimate collection.",
                actionTitle: "Browse games",
                actionIcon: .forward,
                onAction: onBrowseGames
            )
            .frame(maxHeight: .infinity)
        } else if viewModel.entries.isEmpty {
            EmptyState(
                icon: .library,
                title: "Nothing here yet",
                message: "No games marked as \u{201C}\(viewModel.filter?.rawValue ?? "")\u{201D}."
            )
            .frame(maxHeight: .infinity)
        } else {
            LibraryList(
                entries: viewModel.entries,
                canLoadMore: viewModel.canLoadMore,
                isLoadingMore: viewModel.isLoadingMore,
                loadMoreFailed: viewModel.loadMoreFailed,
                onLoadMore: { Task { await viewModel.loadMore() } },
                onToggleFavorite: viewModel.onToggleFavorite,
                onGameSelect: onGameSelect
            )
        }
    }
}

#Preview("Library") {
    @Previewable @State var viewModel = LibraryViewModel(repository: FakeLibraryRepository())
    LibraryView(viewModel: viewModel)
        .environment(AuthStore())
        .task { await viewModel.loadFor(1) }
        .preferredColorScheme(.dark)
}

#Preview("Error") {
    @Previewable @State var viewModel = LibraryViewModel(repository: FakeLibraryRepository(
        failure: APIError.networkFailure,
        latency: .zero
    ))
    LibraryView(viewModel: viewModel)
        .environment(AuthStore())
        .task { await viewModel.loadFor(1) }
        .preferredColorScheme(.dark)
}
