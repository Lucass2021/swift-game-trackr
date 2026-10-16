import SwiftUI

private enum Constants {
    static let loadMoreThreshold = 2
}

struct LibraryList: View {
    let entries: [LibraryEntry]
    let canLoadMore: Bool
    let isLoadingMore: Bool
    let loadMoreFailed: Bool
    let onLoadMore: () -> Void
    let onToggleFavorite: (String) -> Void
    let onGameSelect: (String) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: Spacing.sm) {
                ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                    Button { onGameSelect(entry.slug) } label: {
                        LibraryEntryRow(entry: entry, onFavorite: { onToggleFavorite(entry.slug) })
                    }
                    .buttonStyle(PressableButtonStyle())
                    .onAppear {
                        if canLoadMore, index >= entries.count - Constants.loadMoreThreshold {
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
            .padding(.bottom, Spacing.xl)
        }
    }
}

#Preview {
    LibraryList(
        entries: LibraryMockData.entries,
        canLoadMore: false,
        isLoadingMore: false,
        loadMoreFailed: true,
        onLoadMore: {},
        onToggleFavorite: { _ in },
        onGameSelect: { _ in }
    )
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
