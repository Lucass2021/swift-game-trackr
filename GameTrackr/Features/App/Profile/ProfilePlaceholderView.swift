import SwiftUI

struct ProfilePlaceholderView: View {
    @Environment(AuthStore.self) private var authStore

    var body: some View {
        ComingSoonView(
            icon: .avatar,
            title: authStore.isGuest ? "Guest" : (authStore.currentUser?.name ?? "Profile"),
            subtitle: authStore.isGuest
                ? "Create an account to build a public profile with your stats."
                : "Your public profile and stats are coming next."
        )
    }
}

#Preview {
    ProfilePlaceholderView()
        .environment(AuthStore())
        .preferredColorScheme(.dark)
}
