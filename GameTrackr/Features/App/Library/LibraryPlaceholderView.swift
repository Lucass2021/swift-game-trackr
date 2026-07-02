import SwiftUI

struct LibraryPlaceholderView: View {
    var body: some View {
        ComingSoonView(
            icon: "square.stack",
            title: "Library",
            subtitle: "Track the games you own and their status. Coming next."
        )
    }
}

#Preview {
    LibraryPlaceholderView()
        .preferredColorScheme(.dark)
}
