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
        }
    }
}

private struct RootView: View {
    @Environment(AuthStore.self) private var authStore
    @State private var showSplash = true
    @State private var animationFinished = false
    @State private var authResolved = false

    var body: some View {
        ZStack {
            if authStore.isAuthenticated {
                HomePlaceholderView()
            } else {
                WelcomeView()
            }

            if showSplash {
                SplashView {
                    animationFinished = true
                    dismissSplashIfReady()
                }
                .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
        .task {
            await authStore.validate()
            authResolved = true
            dismissSplashIfReady()
        }
    }

    private func dismissSplashIfReady() {
        guard animationFinished, authResolved else { return }
        withAnimation(.easeInOut(duration: 0.4)) {
            showSplash = false
        }
    }
}
