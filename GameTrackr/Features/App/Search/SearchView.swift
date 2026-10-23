import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: SearchViewModel
    @State private var detailSlug: String?
    @FocusState private var searchFocused: Bool

    init(scope: SearchScope = .all, repository: GameRepository = RemoteGameRepository()) {
        _viewModel = State(initialValue: SearchViewModel(scope: scope, repository: repository))
    }

    private var querySelection: Binding<String> {
        Binding(get: { viewModel.query }, set: { viewModel.onQueryChange($0) })
    }

    var body: some View {
        VStack(spacing: 0) {
            SearchTopBar(query: querySelection, isFocused: $searchFocused, onBack: { dismiss() })

            SearchFilterChips(
                platforms: viewModel.platforms,
                selection: viewModel.platforms.first { $0.slug == viewModel.platformSlug },
                onSelect: { platform in Task { await viewModel.onPlatformChange(platform?.slug) } }
            )
            .padding(.top, Spacing.xxxs)
            .padding(.bottom, Spacing.sm)

            results
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .task { await viewModel.loadIfNeeded() }
        .navigationDestination(item: $detailSlug) { slug in
            GameDetailView(slug: slug)
        }
    }

    @ViewBuilder
    private var results: some View {
        if viewModel.hasError {
            EmptyState(
                icon: .info,
                title: "Couldn't load games",
                message: "Check your connection\nand try again.",
                actionTitle: "Try again",
                onAction: { Task { await viewModel.load() } }
            )
            .frame(maxHeight: .infinity)
        } else if viewModel.isWaiting {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.isEmpty {
            SearchResultsEmptyState(query: viewModel.query) {
                Task { await viewModel.onClearFilters() }
            }
            .frame(maxHeight: .infinity)
        } else {
            SearchResultsGrid(viewModel: viewModel, onGameSelect: { detailSlug = $0 })
        }
    }
}

#Preview {
    NavigationStack {
        SearchView(repository: FakeGameRepository(latency: .zero))
    }
    .preferredColorScheme(.dark)
}
