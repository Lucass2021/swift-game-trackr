import SwiftUI

struct MainTabView: View {
    @State private var selection: AppTab = .home
    @State private var searchScope: SearchScope?
    @State private var showNotifications = false
    @State private var showMenu = false
    @State private var showGameDetail = false
    @State private var detailSlug: String?
    @State private var showStats = false
    @State private var showEditProfile = false
    @State private var showSetup = false
    @State private var libraryFilter: LibraryStatus?
    @Environment(AuthStore.self) private var authStore
    @State private var profile = ProfileMockData.profile
    @State private var setups: [SetupItem] = []

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
            .navigationDestination(isPresented: $showSetup) { MySetupView(setups: $setups) }
            .navigationDestination(isPresented: $showGameDetail) {
                GameDetailView(slug: detailSlug)
            }
            .task(id: authStore.currentUser?.id) {
                profile = profile.applying(authStore.currentUser)
            }
        }
    }

    private func openGameDetail(slug: String?) {
        detailSlug = slug
        showGameDetail = true
    }

    @ViewBuilder
    private var content: some View {
        switch selection {
        case .home:
            HomeView(onViewAll: { searchScope = $0 }, onGameSelect: { openGameDetail(slug: $0) })
        case .library:
            LibraryView(
                filter: $libraryFilter,
                onBrowseGames: { searchScope = .all },
                onGameSelect: { openGameDetail(slug: nil) }
            )
        case .community:
            CommunityView()
        case .profile:
            ProfileView(
                profile: profile,
                setups: setups,
                onGameSelect: { openGameDetail(slug: nil) },
                onStatusSelect: { status in
                    libraryFilter = status
                    selection = .library
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
