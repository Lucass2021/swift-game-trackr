import SwiftUI

struct SearchView: View {
    var scope: SearchScope = .all
    var onExploreCommunity: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var platform: GamePlatform?
    @State private var showGameDetail = false
    @State private var pagination = MockPaginationState(allItems: SearchMockData.games, pageSize: 4)
    @FocusState private var searchFocused: Bool

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
        .navigationDestination(isPresented: $showGameDetail) {
            GameDetailView()
        }
    }

    private var filteredGames: [SearchGame] {
        pagination.items.filter { game in
            let matchesPlatform = platform.map { game.platforms.contains($0) } ?? true
            let matchesQuery = query.trimmingCharacters(in: .whitespaces).isEmpty
                || game.title.localizedCaseInsensitiveContains(query)
            return matchesPlatform && matchesQuery
        }
    }

    private var results: some View {
        let games = filteredGames
        return ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                if games.isEmpty {
                    SearchResultsEmptyState(query: query) {
                        query = ""
                        platform = nil
                    }
                } else {
                    sectionHeader(count: games.count)
                    grid(games)
                }

                ExploreCommunityCard(onExplore: onExploreCommunity)
                    .padding(.horizontal, 20)
            }
            .padding(.top, 6)
            .padding(.bottom, 28)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var sectionTitle: String {
        if !query.isEmpty { return "Results" }
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

    private func grid(_ games: [SearchGame]) -> some View {
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
                            Task { await pagination.loadNextPage() }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)

            if pagination.isLoadingMore {
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
