import SwiftUI

struct MainTabView: View {
    @State private var selection: AppTab = .home
    @State private var route: ShellRoute?
    @Environment(AuthStore.self) private var authStore
    @State private var mySetupViewModel = MySetupViewModel()
    @State private var library = LibraryDependencies()
    @State private var profileViewModel = ProfileViewModel(repository: FakeProfileOverviewRepository())
    @State private var community = CommunityDependencies()
    @State private var homeViewModel = HomeViewModel(repository: RemoteGameRepository())

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppHeader(
                    onNotifications: { route = .notifications },
                    onSearch: { route = .search(.all) },
                    onMenu: { route = .menu }
                )

                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                AppTabBar(selection: $selection)
            }
            .background(Color.appBackground)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $route) { destinationView($0) }
            .task(id: authStore.currentUser?.id) {
                let userId = authStore.isGuest ? nil : authStore.currentUser?.id
                async let setups: Void = mySetupViewModel.loadFor(userId)
                async let libraryEntries: Void = library.viewModel.loadFor(userId)
                async let profileOverview: Void = profileViewModel.loadFor(userId)
                _ = await (setups, libraryEntries, profileOverview)
            }
        }
        .environment(library)
    }

    private var profile: Profile? {
        authStore.currentUser.map(Profile.init(user:))
    }

    @ViewBuilder
    private var content: some View {
        switch selection {
        case .home:
            HomeView(
                viewModel: homeViewModel,
                onViewAll: { route = .search($0) },
                onGameSelect: { route = .gameDetail(slug: $0) }
            )
        case .library:
            LibraryView(
                viewModel: library.viewModel,
                onBrowseGames: { route = .search(.all) },
                onGameSelect: { route = .gameDetail(slug: $0) }
            )
        case .community:
            CommunityView(dependencies: community)
        case .profile:
            ProfileView(
                viewModel: profileViewModel,
                profile: profile,
                setups: mySetupViewModel.setups,
                onGameSelect: { route = .gameDetail(slug: $0) },
                onStatusSelect: { status in
                    selection = .library
                    Task { await library.viewModel.onFilterChange(status) }
                },
                onEditProfile: { route = .editProfile },
                onViewStats: { route = .stats },
                onViewSetup: { route = .mySetup }
            )
        }
    }

    @ViewBuilder
    private func destinationView(_ route: ShellRoute) -> some View {
        switch route {
        case let .search(scope): SearchView(scope: scope)
        case .notifications: NotificationsView()
        case .menu: ProfileMenuView()
        case let .gameDetail(slug): GameDetailView(slug: slug)
        case .stats: StatsView()
        case .editProfile:
            if let profile { EditProfileView(profile: profile) }
        case .mySetup: MySetupView(viewModel: mySetupViewModel)
        }
    }
}

#Preview {
    MainTabView()
        .environment(AuthStore())
        .preferredColorScheme(.dark)
}
