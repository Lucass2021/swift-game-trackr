import SwiftUI

struct UserProfileView: View {
    let username: String

    @Environment(AuthStore.self) private var authStore
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: UserProfileViewModel
    @State private var showStats = false
    @State private var detailSlug: String?

    init(username: String, repository: ProfileOverviewRepository = FakeProfileOverviewRepository()) {
        self.username = username
        _viewModel = State(initialValue: UserProfileViewModel(username: username, repository: repository))
    }

    var body: some View {
        VStack(spacing: 0) {
            UserProfileTopBar(username: "@\(username)", onBack: { dismiss() })

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showStats) {
            StatsView(ownerName: "@\(username)")
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
                shareText: "Check out \(profile.name)'s gaming profile on GameTrackr!",
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
        UserProfileView(username: UserProfileMockData.username)
    }
    .environment(AuthStore())
    .environment(AppDependencies())
    .preferredColorScheme(.dark)
}

#Preview("Friend") {
    NavigationStack {
        UserProfileView(
            username: UserProfileMockData.username,
            repository: FakeProfileOverviewRepository(friendUsernames: [UserProfileMockData.username])
        )
    }
    .environment(AuthStore())
    .environment(AppDependencies())
    .preferredColorScheme(.dark)
}

#Preview("Error") {
    NavigationStack {
        UserProfileView(
            username: UserProfileMockData.username,
            repository: FakeProfileOverviewRepository(failure: APIError.networkFailure, latency: .zero)
        )
    }
    .environment(AuthStore())
    .environment(AppDependencies())
    .preferredColorScheme(.dark)
}
