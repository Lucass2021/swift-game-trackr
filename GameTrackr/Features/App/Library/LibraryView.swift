import SwiftUI

struct LibraryView: View {
    @Binding var filter: LibraryStatus?
    var onBrowseGames: () -> Void = {}
    var onGameSelect: () -> Void = {}

    @State private var pagination = MockPaginationState(allItems: LibraryMockData.entries, pageSize: 3)

    private var filteredEntries: [LibraryEntry] {
        guard let filter else { return pagination.items }
        return pagination.items.filter { $0.status == filter }
    }

    var body: some View {
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
                            LibraryEntryRow(entry: entry)
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
