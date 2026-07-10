import SwiftUI

struct LibraryView: View {
    var onBrowseGames: () -> Void = {}
    var onGameSelect: () -> Void = {}

    @State private var filter: LibraryStatus?

    private let entries = LibraryMockData.entries

    private var filteredEntries: [LibraryEntry] {
        guard let filter else { return entries }
        return entries.filter { $0.status == filter }
    }

    var body: some View {
        VStack(spacing: 0) {
            if !entries.isEmpty {
                LibraryStatsBar(stats: LibraryMockData.stats)
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 16)
            }

            LibraryFilterChips(selection: $filter)
                .padding(.top, entries.isEmpty ? 12 : 0)
                .padding(.bottom, 14)

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }

    @ViewBuilder
    private var content: some View {
        if entries.isEmpty {
            LibraryEmptyState(onBrowse: onBrowseGames)
        } else if filteredEntries.isEmpty {
            filterEmptyState
        } else {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 14) {
                    ForEach(filteredEntries) { entry in
                        Button(action: onGameSelect) {
                            LibraryEntryRow(entry: entry)
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
    }

    private var filterEmptyState: some View {
        VStack(spacing: 8) {
            Text("Nothing here yet")
                .font(.appHeadline(20, weight: .heavy))
                .foregroundStyle(Color.appTextPrimary)

            Text("No games marked as \u{201C}\(filter?.rawValue ?? "")\u{201D}.")
                .font(.appBody(15))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }
}

#Preview("Library") {
    LibraryView()
        .preferredColorScheme(.dark)
}
