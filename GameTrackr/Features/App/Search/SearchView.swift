import SwiftUI

struct SearchView: View {
    var scope: SearchScope = .all

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var platform: GamePlatform?
    @State private var showGameDetail = false
    @State private var viewModel = SearchViewModel()
    @FocusState private var searchFocused: Bool

    private var hasFeed: Bool {
        scope != .mostAnticipated
    }

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespaces)
    }

    private var isFiltering: Bool {
        platform != nil || !trimmedQuery.isEmpty
    }

    private var filteredGames: [Game] {
        viewModel.games.filter { game in
            let matchesPlatform = platform.map { game.platforms.contains($0) } ?? true
            let matchesQuery = trimmedQuery.isEmpty || game.name.localizedCaseInsensitiveContains(trimmedQuery)
            return matchesPlatform && matchesQuery
        }
    }

    private var isStillSearching: Bool {
        !viewModel.hasLoaded || viewModel.isLoading || (isFiltering && viewModel.canFetchMoreForFilter)
    }

    private var autoFetchKey: String {
        "\(platform?.rawValue ?? "-")|\(trimmedQuery)|\(viewModel.games.count)"
    }

    var body: some View {
        VStack(spacing: 0) {
            SearchTopBar(query: $query, isFocused: $searchFocused, onBack: { dismiss() })

            SearchFilterChips(selection: $platform)
                .padding(.top, 2)
                .padding(.bottom, 14)

            results
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .task {
            guard hasFeed else { return }
            await viewModel.loadNewReleases()
        }
        .task(id: autoFetchKey) {
            guard hasFeed, isFiltering, filteredGames.isEmpty else { return }
            guard viewModel.canFetchMoreForFilter, !viewModel.isLoadingMore else { return }
            await viewModel.loadMoreForFilter()
        }
        .onChange(of: platform) { viewModel.resetFilterBudget() }
        .onChange(of: trimmedQuery) { viewModel.resetFilterBudget() }
        .navigationDestination(isPresented: $showGameDetail) {
            GameDetailView()
        }
    }

    @ViewBuilder
    private var results: some View {
        let games = filteredGames

        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                if !hasFeed {
                    SearchResultsEmptyState(
                        title: "Not available yet",
                        message: "The most anticipated feed is still\nwaiting on the backend."
                    )
                } else if games.isEmpty, isStillSearching {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                } else if games.isEmpty {
                    SearchResultsEmptyState(query: query) {
                        query = ""
                        platform = nil
                    }
                } else {
                    sectionHeader(count: games.count)
                    grid(games)
                }
            }
            .padding(.top, 6)
            .padding(.bottom, 28)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var sectionTitle: String {
        if !trimmedQuery.isEmpty { return "Results" }
        return scope.isFiltered ? scope.title : "Recent Releases"
    }

    private func sectionHeader(count: Int) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(sectionTitle)
                .font(.appHeadline(22))
                .foregroundStyle(Color.appTextPrimary)

            Spacer()

            Text("\(count) result\(count == 1 ? "" : "s")")
                .font(.appBody(14))
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(.horizontal, 20)
    }

    private func grid(_ games: [Game]) -> some View {
        VStack(spacing: 0) {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ],
                alignment: .leading,
                spacing: 20
            ) {
                ForEach(Array(games.enumerated()), id: \.element.id) { index, game in
                    Button {
                        showGameDetail = true
                    } label: {
                        SearchResultCard(game: game)
                    }
                    .buttonStyle(PressableButtonStyle())
                    .onAppear {
                        if index >= games.count - 2 {
                            Task { await viewModel.loadMoreNewReleases() }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)

            if viewModel.isLoadingMore {
                LoadingMoreIndicator()
            }
        }
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
    .preferredColorScheme(.dark)
}
