import SwiftUI

struct ProfileView: View {
    let viewModel: ProfileViewModel
    var profile: Profile = ProfileMockData.profile
    var setups: [SetupItem] = []
    var onGameSelect: (String) -> Void = { _ in }
    var onStatusSelect: (LibraryStatus?) -> Void = { _ in }
    var onEditProfile: () -> Void = {}
    var onViewStats: () -> Void = {}
    var onViewSetup: () -> Void = {}

    @Environment(AuthStore.self) private var authStore

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground)
    }

    @ViewBuilder
    private var content: some View {
        if authStore.isGuest {
            ProfileGuestState(onCreateAccount: { authStore.logout() })
        } else if let overview = viewModel.overview {
            ProfileContent(
                overview: overview,
                profile: profile,
                setups: setups,
                onGameSelect: onGameSelect,
                onStatusSelect: onStatusSelect,
                onEditProfile: onEditProfile,
                onViewStats: onViewStats,
                onViewSetup: onViewSetup
            )
        } else if viewModel.hasError {
            EmptyState(
                icon: .info,
                title: "Couldn't load your profile",
                message: "Check your connection and try again.",
                actionTitle: "Try again",
                onAction: { Task { await viewModel.load() } }
            )
        } else {
            ProgressView()
                .tint(Color.appPrimary)
        }
    }
}

#Preview("Signed in") {
    let viewModel = ProfileViewModel(repository: FakeProfileOverviewRepository(latency: .zero))
    return ProfileView(viewModel: viewModel)
        .task { await viewModel.loadFor(1) }
        .environment(AuthStore())
        .preferredColorScheme(.dark)
}

#Preview("Error") {
    let viewModel = ProfileViewModel(repository: FakeProfileOverviewRepository(
        failure: APIError.networkFailure,
        latency: .zero
    ))
    return ProfileView(viewModel: viewModel)
        .task { await viewModel.loadFor(1) }
        .environment(AuthStore())
        .preferredColorScheme(.dark)
}

#Preview("Guest") {
    let authStore = AuthStore()
    authStore.continueAsGuest()
    return ProfileView(viewModel: ProfileViewModel(repository: FakeProfileOverviewRepository()))
        .environment(authStore)
        .preferredColorScheme(.dark)
}
