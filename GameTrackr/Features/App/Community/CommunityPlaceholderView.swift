import SwiftUI

struct CommunityPlaceholderView: View {
    var body: some View {
        ComingSoonView(
            icon: "person.3",
            title: "Community",
            subtitle: "Join topics, discover communities, and talk games. Coming next."
        )
    }
}

#Preview {
    CommunityPlaceholderView()
        .preferredColorScheme(.dark)
}
