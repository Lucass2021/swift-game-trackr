import SwiftUI

struct UserProfileView: View {
    let user: UserProfile

    @Environment(AuthStore.self) private var authStore
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: UserProfileViewModel
    @State private var showStats = false
    @State private var detailSlug: String?

    init(user: UserProfile, repository: ProfileOverviewRepository = FakeProfileOverviewRepository()) {
        self.user = user
        _viewModel = State(initialValue: UserProfileViewModel(user: user, repository: repository))
    }

    var body: some View {
        VStack(spacing: 0) {
            UserProfileTopBar(username: user.username, onBack: { dismiss() })

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showStats) {
            StatsView(ownerName: user.username)
        }
        .navigationDestination(item: $detailSlug) { slug in
            GameDetailView(slug: slug)
        }
        .toast(message: $viewModel.toastMessage)
        .task { await viewModel.loadIfNeeded() }
    }

    @ViewBuilder
    private var content: some View {
        if let profile = viewModel.profile, let overview = viewModel.overview {
            UserProfileContent(
                profile: profile,
                overview: overview,
                isFriend: viewModel.isFriend,
                isGuest: authStore.isGuest,
                shareText: "Check out \(user.name)'s gaming profile on GameTrackr!",
                onFriendAction: { Task { await viewModel.onFriendAction(isGuest: authStore.isGuest) } },
                onMessage: { viewModel.onMessage(isGuest: authStore.isGuest) },
                onGameSelect: { detailSlug = $0 },
                onViewStats: { showStats = true }
            )
        } else if viewModel.hasError {
            EmptyState(
                icon: .info,
                title: "Couldn't load this profile",
                message: "Check your connection and try again.",
                actionTitle: "Try again",
                onAction: { Task { await viewModel.load() } }
            )
            .frame(maxHeight: .infinity)
        } else {
            ProgressView()
                .tint(Color.appPrimary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview("Not friend") {
    NavigationStack {
        UserProfileView(user: UserProfileMockData.user)
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}

#Preview("Friend") {
    NavigationStack {
        UserProfileView(
            user: UserProfileMockData.friend,
            repository: FakeProfileOverviewRepository(friendUsernames: [UserProfileMockData.friend.username])
        )
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}

#Preview("Error") {
    NavigationStack {
        UserProfileView(
            user: UserProfileMockData.user,
            repository: FakeProfileOverviewRepository(failure: APIError.networkFailure, latency: .zero)
        )
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
