import SwiftUI

@main
struct GameTrackrApp: App {
    @State private var authStore = AuthStore()

    init() {
        AppFonts.register()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authStore)
                .preferredColorScheme(.dark)
        }
    }
}

private struct RootView: View {
    @Environment(AuthStore.self) private var authStore

    var body: some View {
        if authStore.isAuthenticated {
            HomePlaceholderView()
        } else {
            WelcomeView()
        }
    }
}
