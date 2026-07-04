import SwiftUI

struct SearchPlaceholderView: View {
    var body: some View {
        ComingSoonView(
            icon: .search,
            title: "Search",
            subtitle: "Search the game catalog. Coming next."
        )
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SearchPlaceholderView()
    }
    .preferredColorScheme(.dark)
}
