import SwiftUI

struct NotificationsPlaceholderView: View {
    var body: some View {
        ComingSoonView(
            icon: .notifications,
            title: "Notifications",
            subtitle: "Friend requests, replies, and messages will show up here."
        )
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        NotificationsPlaceholderView()
    }
    .preferredColorScheme(.dark)
}
