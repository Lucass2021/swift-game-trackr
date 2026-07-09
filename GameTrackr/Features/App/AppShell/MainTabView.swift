import SwiftUI

struct MainTabView: View {
    @State private var selection: AppTab = .home
    @State private var searchScope: SearchScope?
    @State private var showNotifications = false
    @State private var showMenu = false

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
                SearchView(scope: scope, onExploreCommunity: {
                    searchScope = nil
                    selection = .community
                })
            }
            .navigationDestination(isPresented: $showNotifications) { NotificationsView() }
            .navigationDestination(isPresented: $showMenu) { ProfileMenuView() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch selection {
        case .home: HomeView(onViewAll: { searchScope = $0 })
        case .library: LibraryView(onBrowseGames: { searchScope = .all })
        case .community: CommunityPlaceholderView()
        case .profile: ProfilePlaceholderView()
        }
    }
}

#Preview {
    MainTabView()
        .environment(AuthStore())
        .preferredColorScheme(.dark)
}
