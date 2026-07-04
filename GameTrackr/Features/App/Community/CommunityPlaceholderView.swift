import SwiftUI

struct CommunityPlaceholderView: View {
    var body: some View {
        ComingSoonView(
            icon: .community,
            title: "Community",
            subtitle: "Join topics, discover communities, and talk games. Coming next."
        )
    }
}

#Preview {
    CommunityPlaceholderView()
        .preferredColorScheme(.dark)
}
