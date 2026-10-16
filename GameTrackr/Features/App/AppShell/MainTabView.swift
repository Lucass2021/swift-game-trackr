import SwiftUI

struct MainTabView: View {
    @State private var selection: AppTab = .home
    @State private var searchScope: SearchScope?
    @State private var showNotifications = false
    @State private var showMenu = false
    @State private var detailSlug: String?
    @State private var showStats = false
    @State private var showEditProfile = false
    @State private var showSetup = false
    @Environment(AuthStore.self) private var authStore
    @State private var profile = ProfileMockData.profile
    @State private var mySetupViewModel = MySetupViewModel()
    @State private var libraryViewModel = LibraryViewModel(repository: FakeLibraryRepository())

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppHeader(
                    onNotifications: { showNotifications = true },
                    onSearch: { searchScope = .all },
                    onMenu: { showMenu = true }
                )

                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                AppTabBar(selection: $selection)
            }
            .background(Color.appBackground)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $searchScope) { scope in
                SearchView(scope: scope)
            }
            .navigationDestination(isPresented: $showNotifications) { NotificationsView() }
            .navigationDestination(isPresented: $showMenu) { ProfileMenuView(profile: $profile) }
            .navigationDestination(isPresented: $showStats) { StatsView() }
            .navigationDestination(isPresented: $showEditProfile) { EditProfileView(profile: $profile) }
            .navigationDestination(isPresented: $showSetup) { MySetupView(viewModel: mySetupViewModel) }
            .navigationDestination(item: $detailSlug) { slug in
                GameDetailView(slug: slug)
            }
            .task(id: authStore.currentUser?.id) {
                profile = profile.applying(authStore.currentUser)
                let userId = authStore.isGuest ? nil : authStore.currentUser?.id
                async let setups: Void = mySetupViewModel.loadFor(userId)
                async let library: Void = libraryViewModel.loadFor(userId)
                _ = await (setups, library)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch selection {
        case .home:
            HomeView(onViewAll: { searchScope = $0 }, onGameSelect: { detailSlug = $0 })
        case .library:
            LibraryView(
                viewModel: libraryViewModel,
                onBrowseGames: { searchScope = .all },
                onGameSelect: { detailSlug = $0 }
            )
        case .community:
            CommunityView()
        case .profile:
            ProfileView(
                profile: profile,
                setups: mySetupViewModel.setups,
                onGameSelect: { detailSlug = $0 },
                onStatusSelect: { status in
                    selection = .library
                    Task { await libraryViewModel.onFilterChange(status) }
                },
                onEditProfile: { showEditProfile = true },
                onViewStats: { showStats = true },
                onViewSetup: { showSetup = true }
            )
        }
    }
}

#Preview {
    MainTabView()
        .environment(AuthStore())
        .preferredColorScheme(.dark)
}
