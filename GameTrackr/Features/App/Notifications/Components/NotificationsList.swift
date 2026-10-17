import SwiftUI

private enum Constants {
    static let loadMoreThreshold = 2
    static let sectionTitleSize: CGFloat = 12
    static let sectionTitleTracking: CGFloat = 1
}

struct NotificationsList: View {
    let sections: [NotificationSectionGroup]
    let canLoadMore: Bool
    let isLoadingMore: Bool
    let loadMoreFailed: Bool
    let onLoadMore: () -> Void
    let onAcceptFriendRequest: (Int) -> Void
    let onDeclineFriendRequest: (Int) -> Void

    private var itemIds: [Int] {
        sections.flatMap { $0.items.map(\.id) }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: Spacing.sm) {
                ForEach(sections) { group in
                    sectionHeader(group.section)
                    ForEach(group.items) { item in
                        NotificationRow(
                            item: item,
                            onAccept: { onAcceptFriendRequest(item.id) },
                            onDecline: { onDeclineFriendRequest(item.id) }
                        )
                        .onAppear { loadMoreIfNeeded(after: item.id) }
                    }
                }

                if isLoadingMore {
                    LoadingMoreIndicator()
                }

                if loadMoreFailed {
                    LoadMoreErrorRow(onRetry: onLoadMore)
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.xl)
        }
    }

    private func sectionHeader(_ section: NotificationSection) -> some View {
        Text(section.rawValue.uppercased())
            .font(.appLabel(Constants.sectionTitleSize))
            .tracking(Constants.sectionTitleTracking)
            .foregroundStyle(Color.appTextSecondary)
            .padding(.horizontal, Spacing.xxs)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.xxs)
    }

    private func loadMoreIfNeeded(after id: Int) {
        guard canLoadMore, let index = itemIds.firstIndex(of: id) else { return }
        if index >= itemIds.count - Constants.loadMoreThreshold {
            onLoadMore()
        }
    }
}

#Preview {
    NotificationsList(
        sections: [
            NotificationSectionGroup(section: .new, items: Array(NotificationsMockData.items.prefix(3))),
            NotificationSectionGroup(section: .today, items: [NotificationsMockData.items[3]])
        ],
        canLoadMore: false,
        isLoadingMore: false,
        loadMoreFailed: true,
        onLoadMore: {},
        onAcceptFriendRequest: { _ in },
        onDeclineFriendRequest: { _ in }
    )
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
