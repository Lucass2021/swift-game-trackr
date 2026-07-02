import SwiftUI

struct HomePlaceholderView: View {
    @Environment(AuthStore.self) private var authStore

    var body: some View {
        ComingSoonView(
            icon: "safari",
            title: greeting,
            subtitle: "Discover new releases and the most anticipated games. The feed is coming next."
        )
    }

    private var greeting: String {
        if authStore.isGuest { return "Welcome, guest!" }
        return "Welcome\(authStore.currentUser.map { ", \($0.name)" } ?? "")!"
    }
}

#Preview {
    HomePlaceholderView()
        .environment(AuthStore())
        .preferredColorScheme(.dark)
}
