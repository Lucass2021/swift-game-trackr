import SwiftUI

struct NotificationsView: View {
    @Environment(AuthStore.self) private var authStore
    @Environment(\.dismiss) private var dismiss

    @State private var filter: NotificationFilter = .all
    @State private var markedAllRead = false
    @State private var removedIDs: Set<UUID> = []

    var body: some View {
        VStack(spacing: 0) {
            NotificationsTopBar(
                onBack: { dismiss() },
                onMarkAllRead: { markedAllRead = true },
                showMarkAllRead: !authStore.isGuest
            )

            if authStore.isGuest {
                guestState
            } else {
                signedInContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }

    private var guestState: some View {
        NotificationsEmptyState(
            title: "Notifications need an account",
            subtitle: "You're browsing as a guest. Create an account to get friend requests, replies, and messages.",
            actionTitle: "Create an account",
            onAction: { authStore.logout() }
        )
    }

    @ViewBuilder
    private var signedInContent: some View {
        let items = visibleItems
        VStack(spacing: 0) {
            NotificationFilterTabs(selection: $filter)
                .padding(.top, 4)
                .padding(.bottom, 8)

            if items.isEmpty {
                NotificationsEmptyState(
                    title: "You're all caught up",
                    subtitle: "New notifications will show up here."
                )
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 12, pinnedViews: []) {
                        ForEach(NotificationSection.allCases, id: \.self) { section in
                            let sectionItems = items.filter { $0.section == section }
                            if !sectionItems.isEmpty {
                                sectionHeader(section)
                                ForEach(sectionItems) { item in
                                    NotificationRow(
                                        item: item,
                                        markedAllRead: markedAllRead,
                                        onAccept: { remove(item) },
                                        onDecline: { remove(item) }
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private func sectionHeader(_ section: NotificationSection) -> some View {
        Text(section.rawValue.uppercased())
            .font(.appLabel(12))
            .tracking(1)
            .foregroundStyle(Color.appTextSecondary)
            .padding(.horizontal, 4)
            .padding(.top, 18)
            .padding(.bottom, 4)
    }

    private var visibleItems: [NotificationItem] {
        NotificationsMockData.items.filter { item in
            guard !removedIDs.contains(item.id) else { return false }
            switch filter {
            case .all: return true
            case .unread: return item.unread && !markedAllRead
            case .mentions: return item.isMention
            }
        }
    }

    private func remove(_ item: NotificationItem) {
        _ = withAnimation { removedIDs.insert(item.id) }
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
