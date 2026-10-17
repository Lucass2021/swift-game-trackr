import SwiftUI

struct NotificationsView: View {
    @Environment(AuthStore.self) private var authStore
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: NotificationsViewModel

    init(repository: NotificationsRepository = FakeNotificationsRepository()) {
        _viewModel = State(initialValue: NotificationsViewModel(repository: repository))
    }

    var body: some View {
        VStack(spacing: 0) {
            NotificationsTopBar(
                onBack: { dismiss() },
                onMarkAllRead: { Task { await viewModel.onMarkAllRead() } },
                onClearAll: { Task { await viewModel.onClearAll() } },
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
        .toast(message: $viewModel.errorMessage)
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

    private var signedInContent: some View {
        VStack(spacing: 0) {
            NotificationFilterTabs(selection: viewModel.filter) { filter in
                Task { await viewModel.onFilterChange(filter) }
            }
            .padding(.top, Spacing.xxs)
            .padding(.bottom, Spacing.xs)

            content
        }
        .task { await viewModel.loadIfNeeded() }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.hasError {
            EmptyState(
                icon: .info,
                title: "Couldn't load notifications",
                message: "Check your connection and try again.",
                actionTitle: "Try again",
                onAction: { Task { await viewModel.load() } }
            )
            .frame(maxHeight: .infinity)
        } else if viewModel.currentPage == 0 {
            ProgressView()
                .tint(Color.appPrimary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.items.isEmpty {
            EmptyState(
                icon: .notifications,
                title: "You're all caught up",
                message: "New notifications will show up here."
            )
            .frame(maxHeight: .infinity)
        } else {
            NotificationsList(
                sections: viewModel.sections,
                canLoadMore: viewModel.canLoadMore,
                isLoadingMore: viewModel.isLoadingMore,
                loadMoreFailed: viewModel.loadMoreFailed,
                onLoadMore: { Task { await viewModel.loadMore() } },
                onAcceptFriendRequest: { id in Task { await viewModel.onAcceptFriendRequest(id) } },
                onDeclineFriendRequest: { id in Task { await viewModel.onDeclineFriendRequest(id) } }
            )
        }
    }
}

#Preview("Signed in") {
    NavigationStack {
        NotificationsView()
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}

#Preview("Error") {
    NavigationStack {
        NotificationsView(
            repository: FakeNotificationsRepository(failure: APIError.networkFailure, latency: .zero)
        )
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}

#Preview("Guest") {
    let authStore = AuthStore()
    authStore.continueAsGuest()
    return NavigationStack {
        NotificationsView()
    }
    .environment(authStore)
    .preferredColorScheme(.dark)
}
