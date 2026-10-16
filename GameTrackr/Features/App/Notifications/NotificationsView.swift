import SwiftUI

struct NotificationsView: View {
    @Environment(AuthStore.self) private var authStore
    @Environment(\.dismiss) private var dismiss

    var repository: NotificationsRepository = FakeNotificationsRepository()

    @State private var filter: NotificationFilter = .all
    @State private var markedAllRead = false
    @State private var removedIDs: Set<Int> = []
    @State private var pagination = PaginationState<NotificationItem>()

    private enum Constants {
        static let notificationsPageSize = 4
    }

    var body: some View {
        VStack(spacing: 0) {
            NotificationsTopBar(
                onBack: { dismiss() },
                onMarkAllRead: { Task { await markAllAsRead() } },
                onClearAll: { Task { await clearAll() } },
                showActions: !authStore.isGuest
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
        EmptyState(
            icon: .notifications,
            title: "Notifications need an account",
            message: "You're browsing as a guest. Create an account to get friend requests, replies, and messages.",
            actionTitle: "Create an account",
            onAction: { authStore.logout() }
        )
        .frame(maxHeight: .infinity)
    }

    @ViewBuilder
    private var signedInContent: some View {
        let items = visibleItems
        VStack(spacing: 0) {
            NotificationFilterTabs(selection: $filter)
                .padding(.top, 4)
                .padding(.bottom, 8)

            if pagination.currentPage == 0 {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if items.isEmpty {
                EmptyState(
                    icon: .notifications,
                    title: "You're all caught up",
                    message: "New notifications will show up here."
                )
                .frame(maxHeight: .infinity)
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
                                    .onAppear {
                                        if item.id == items.last?.id {
                                            Task { await loadNextPage() }
                                        }
                                    }
                                }
                            }
                        }

                        if pagination.isLoadingMore {
                            LoadingMoreIndicator()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .task {
            guard pagination.currentPage == 0 else { return }
            await loadNextPage()
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
        pagination.items.filter { item in
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

    private func loadNextPage() async {
        guard pagination.canLoadMore else { return }
        pagination.setLoading(true)
        if let page = try? await repository.fetchNotifications(
            page: pagination.currentPage + 1,
            perPage: Constants.notificationsPageSize
        ) {
            pagination.append(page: page)
        }
        pagination.setLoading(false)
    }

    private func markAllAsRead() async {
        guard await (try? repository.markAllAsRead()) != nil else { return }
        markedAllRead = true
    }

    private func clearAll() async {
        guard await (try? repository.clearNotifications()) != nil else { return }
        withAnimation {
            for item in pagination.items {
                removedIDs.insert(item.id)
            }
        }
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
