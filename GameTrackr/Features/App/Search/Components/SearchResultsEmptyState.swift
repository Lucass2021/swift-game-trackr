import SwiftUI

struct SearchResultsEmptyState: View {
    var query = ""
    var onClear: (() -> Void)?

    var body: some View {
        EmptyState(
            icon: .search,
            title: "No games found",
            message: subtitle,
            actionTitle: "Clear search",
            onAction: onClear
        )
    }

    private var subtitle: String {
        if query.isEmpty {
            return "No games match this filter. Try a different platform."
        }
        return "No results for \u{201C}\(query)\u{201D}. Try another title or platform."
    }
}

#Preview {
    SearchResultsEmptyState(query: "zelda", onClear: {})
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
