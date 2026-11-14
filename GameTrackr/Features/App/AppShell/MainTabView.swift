import SwiftUI

struct MainTabView: View {
    @State private var selection: AppTab = .home
    @State private var route: ShellRoute?
    @Environment(AuthStore.self) private var authStore
    private let dependencies: AppDependencies
    @State private var mySetupViewModel: MySetupViewModel
    @State private var libraryViewModel: LibraryViewModel
    @State private var profileViewModel: ProfileViewModel
    @State private var homeViewModel: HomeViewModel
    @State private var communityFeedViewModel: CommunityFeedViewModel
    @State private var discoverCommunitiesViewModel: DiscoverCommunitiesViewModel

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _mySetupViewModel = State(initialValue: MySetupViewModel(repository: dependencies.setupRepository))
        _libraryViewModel = State(initialValue: LibraryViewModel(
            repository: dependencies.libraryRepository,
            libraryUpdates: dependencies.libraryUpdates
        ))
        _profileViewModel = State(initialValue: ProfileViewModel(repository: dependencies.profileOverviewRepository))
        _homeViewModel = State(initialValue: HomeViewModel(repository: dependencies.gameRepository))
        _communityFeedViewModel = State(initialValue: CommunityFeedViewModel(
            feedRepository: dependencies.communityFeedRepository,
            repository: dependencies.communityRepository,
            postUpdates: dependencies.postUpdates,
            communityUpdates: dependencies.communityUpdates
        ))
        _discoverCommunitiesViewModel = State(initialValue: DiscoverCommunitiesViewModel(
            repository: dependencies.discoverCommunitiesRepository,
            communityUpdates: dependencies.communityUpdates
        ))
    }

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
                async let libraryEntries: Void = libraryViewModel.loadFor(userId)
                async let profileOverview: Void = profileViewModel.loadFor(userId)
                _ = await (setups, libraryEntries, profileOverview)
            }
        }
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
                viewModel: libraryViewModel,
                onBrowseGames: { route = .search(.all) },
                onGameSelect: { route = .gameDetail(slug: $0) }
            )
        case .community:
            CommunityView(feedViewModel: communityFeedViewModel, discoverViewModel: discoverCommunitiesViewModel)
        case .profile:
            ProfileView(
                viewModel: profileViewModel,
                profile: profile,
                setups: mySetupViewModel.setups,
                onGameSelect: { route = .gameDetail(slug: $0) },
                onStatusSelect: { status in
                    selection = .library
                    Task { await libraryViewModel.onFilterChange(status) }
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
        case let .search(scope): SearchView(scope: scope, repository: dependencies.gameRepository)
        case .notifications: NotificationsView(repository: dependencies.notificationsRepository)
        case .menu: ProfileMenuView()
        case let .gameDetail(slug): GameDetailView(slug: slug)
        case .stats: StatsView(repository: dependencies.statsRepository)
        case .editProfile:
            if let profile { EditProfileView(profile: profile, repository: dependencies.profileRepository) }
        case .mySetup: MySetupView(viewModel: mySetupViewModel)
        }
    }
}

#Preview {
    let dependencies = AppDependencies()
    MainTabView(dependencies: dependencies)
        .environment(AuthStore())
        .environment(dependencies)
        .preferredColorScheme(.dark)
}
