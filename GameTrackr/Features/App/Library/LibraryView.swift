import SwiftUI

struct LibraryView: View {
    @Environment(AuthStore.self) private var authStore
    @Binding var filter: LibraryStatus?
    var onBrowseGames: () -> Void = {}
    var onGameSelect: () -> Void = {}

    @State private var pagination = MockPaginationState(allItems: LibraryMockData.entries, pageSize: 3)
    @State private var favoriteIds = Set<UUID>()

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
                if !pagination.items.isEmpty {
                    LibraryStatsBar(stats: LibraryMockData.stats)
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
        }
    }

    private var guestState: some View {
        VStack(spacing: 0) {
            AppIconView(icon: .brand, size: 60)
                .foregroundStyle(Color.appPrimary)
                .frame(width: 128, height: 128)
                .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
                .shadow(color: Color.appPrimary.opacity(0.25), radius: 34)
                .subtleBounce()

            Text("Library needs an account")
                .font(.appHeadline(26, weight: .heavy))
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, 28)

            Text("Create an account to start tracking your games, building your collection, and logging your progress.")
                .font(.appBody(15))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 12)
                .padding(.horizontal, 32)

            Button(action: { authStore.logout() }, label: {
                Text("Create an account")
                    .font(.appLabel(16))
                    .foregroundStyle(Color.appOnPrimary)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 16)
                    .background(Capsule().fill(Color.appPrimary))
                    .shadow(color: Color.appPrimary.opacity(0.35), radius: 24)
                    .contentShape(Capsule())
            })
            .buttonStyle(PressableButtonStyle())
            .padding(.top, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 24)
        .background(Color.appBackground)
    }

    @ViewBuilder
    private var content: some View {
        if pagination.items.isEmpty {
            LibraryEmptyState(onBrowse: onBrowseGames)
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
                                Task { await pagination.loadNextPage() }
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
