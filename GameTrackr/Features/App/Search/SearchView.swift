import SwiftUI

struct SearchView: View {
    var scope: SearchScope = .all

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var platform: GamePlatform?
    @State private var showGameDetail = false
    @State private var detailSlug: String?
    @State private var viewModel = SearchViewModel()
    @State private var hasPendingFilter = false
    @FocusState private var searchFocused: Bool

    private var hasFeed: Bool {
        scope != .mostAnticipated
    }

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespaces)
    }

    private var isStillSearching: Bool {
        !viewModel.hasLoaded || viewModel.isLoading || hasPendingFilter
    }

    private var filterKey: String {
        "\(platform?.rawValue ?? "-")|\(trimmedQuery)"
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
        .task(id: filterKey) {
            guard hasFeed else { return }
            if viewModel.hasLoaded {
                hasPendingFilter = true
                try? await Task.sleep(for: .milliseconds(300))
                guard !Task.isCancelled else { return }
            }
            await viewModel.applyFilters(search: trimmedQuery, platform: platform)
            guard !Task.isCancelled else { return }
            hasPendingFilter = false
        }
        .navigationDestination(isPresented: $showGameDetail) {
            GameDetailView(slug: detailSlug)
        }
    }

    @ViewBuilder
    private var results: some View {
        let games = viewModel.games

        if hasFeed, games.isEmpty, isStillSearching {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    if !hasFeed {
                        SearchResultsEmptyState(
                            title: "Not available yet",
                            message: "The most anticipated feed is still\nwaiting on the backend."
                        )
                    } else if games.isEmpty {
                        SearchResultsEmptyState(query: query) {
                            query = ""
                            platform = nil
                        }
                    } else {
                        sectionHeader(count: viewModel.total)
                        grid(games)
                    }
                }
                .padding(.top, 6)
                .padding(.bottom, 28)
            }
            .scrollDismissesKeyboard(.interactively)
        }
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
                        detailSlug = game.slug
                        showGameDetail = true
                    } label: {
                        SearchResultCard(game: game)
                    }
                    .buttonStyle(PressableButtonStyle())
                    .onAppear {
                        if index >= games.count - 2 {
                            Task { await viewModel.loadMore() }
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
