import SwiftUI

struct LibraryView: View {
    @Environment(AuthStore.self) private var authStore
    @Binding var filter: LibraryStatus?
    var onBrowseGames: () -> Void = {}
    var onGameSelect: () -> Void = {}
    var repository: LibraryRepository = FakeLibraryRepository()

    @State private var pagination = PaginationState<LibraryEntry>()
    @State private var stats: LibraryStats?
    @State private var favoriteIds = Set<UUID>()

    private enum Constants {
        static let entriesPageSize = 3
    }

    private var filteredEntries: [LibraryEntry] {
        let items = pagination.items.map { entry in
            var copy = entry
            copy.isFavorite = favoriteIds.contains(entry.id)
            return copy
        }
        guard let filter else { return items }
        return items.filter { $0.status == filter }
    }

    var body: some View {
        if authStore.isGuest {
            guestState
        } else {
            VStack(spacing: 0) {
                if !pagination.items.isEmpty, let stats {
                    LibraryStatsBar(stats: stats)
                        .padding(.horizontal, 20)
                        .padding(.top, 14)
                        .padding(.bottom, 16)
                }

                LibraryFilterChips(selection: $filter)
                    .padding(.top, pagination.items.isEmpty ? 12 : 0)
                    .padding(.bottom, 14)

                content
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground)
            .task {
                guard pagination.currentPage == 0 else { return }
                await loadNextPage()
            }
            .task {
                guard stats == nil else { return }
                stats = try? await repository.fetchLibraryStats()
            }
        }
    }

    private var guestState: some View {
        LibraryEmptyState(
            title: "Library needs an account",
            message: "Create an account to start tracking your games, building your collection, "
                + "and logging your progress.",
            actionTitle: "Create an account",
            onAction: { authStore.logout() }
        )
        .background(Color.appBackground)
    }

    @ViewBuilder
    private var content: some View {
        if pagination.currentPage == 0 {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if pagination.items.isEmpty {
            LibraryEmptyState(
                title: "Your library is empty",
                message: "Find games to start tracking your journey and building your ultimate collection.",
                actionTitle: "Browse games",
                actionIcon: .forward,
                onAction: onBrowseGames
            )
        } else if filteredEntries.isEmpty {
            filterEmptyState
        } else {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 14) {
                    ForEach(Array(filteredEntries.enumerated()), id: \.element.id) { index, entry in
                        Button(action: onGameSelect) {
                            LibraryEntryRow(
                                entry: entry,
                                onFavorite: { toggleFavorite(entry) }
                            )
                        }
                        .buttonStyle(PressableButtonStyle())
                        .onAppear {
                            if index >= filteredEntries.count - 2 {
                                Task { await loadNextPage() }
                            }
                        }
                    }

                    if pagination.isLoadingMore {
                        LoadingMoreIndicator()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
    }

    private func loadNextPage() async {
        guard pagination.canLoadMore else { return }
        pagination.setLoading(true)
        if let page = try? await repository.fetchLibrary(
            page: pagination.currentPage + 1,
            perPage: Constants.entriesPageSize
        ) {
            pagination.append(page: page)
        }
        pagination.setLoading(false)
    }

    private func toggleFavorite(_ entry: LibraryEntry) {
        if favoriteIds.contains(entry.id) {
            favoriteIds.remove(entry.id)
        } else {
            favoriteIds.insert(entry.id)
        }
    }

    private var filterEmptyState: some View {
        VStack(spacing: 8) {
            Text("Nothing here yet")
                .font(.appHeadline(20, weight: .heavy))
                .foregroundStyle(Color.appTextPrimary)

            Text("No games marked as \u{201C}\(filter?.rawValue ?? "")\u{201D}.")
                .font(.appBody(15))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }
}

#Preview("Library") {
    @Previewable @State var filter: LibraryStatus?
    LibraryView(filter: $filter)
        .preferredColorScheme(.dark)
}
