import SwiftUI

struct ProfileFavoritesSection: View {
    let favorites: [LibraryEntry]
    var onSelect: (LibraryEntry) -> Void = { _ in }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(favorites) { entry in
                    Button {
                        onSelect(entry)
                    } label: {
                        card(entry)
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func card(_ entry: LibraryEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            GameCoverArt(start: entry.coverStart, end: entry.coverEnd, width: 104, height: 138)

            Text(entry.title)
                .font(.appBody(13))
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(width: 104, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    ProfileFavoritesSection(favorites: ProfileMockData.favorites)
        .padding(.vertical, 20)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
