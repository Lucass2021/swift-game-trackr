import SwiftUI

struct MainTabView: View {
    @State private var selection: AppTab = .home
    @State private var showSearch = false
    @State private var showNotifications = false
    @State private var showMenu = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppHeader(
                    onNotifications: { showNotifications = true },
                    onSearch: { showSearch = true },
                    onMenu: { showMenu = true }
                )

                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                AppTabBar(selection: $selection)
            }
            .background(Color.appBackground)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showSearch) { SearchPlaceholderView() }
            .navigationDestination(isPresented: $showNotifications) { NotificationsView() }
            .navigationDestination(isPresented: $showMenu) { ProfileMenuView() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch selection {
        case .home: HomeView()
        case .library: LibraryPlaceholderView()
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
