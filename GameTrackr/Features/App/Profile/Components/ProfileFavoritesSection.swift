import SwiftUI

private enum Constants {
    static let coverWidth: CGFloat = 104
    static let coverHeight: CGFloat = 138
    static let titleSize: CGFloat = 13
}

struct ProfileFavoritesSection: View {
    let favorites: [LibraryEntry]
    var onSelect: (LibraryEntry) -> Void = { _ in }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(favorites) { entry in
                    Button {
                        onSelect(entry)
                    } label: {
                        card(entry)
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            .padding(.horizontal, Spacing.lg)
        }
    }

    private func card(_ entry: LibraryEntry) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            GameCoverArt(
                start: entry.coverStart,
                end: entry.coverEnd,
                width: Constants.coverWidth,
                height: Constants.coverHeight
            )

            Text(entry.title)
                .font(.appBody(Constants.titleSize))
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(width: Constants.coverWidth, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    ProfileFavoritesSection(favorites: ProfileMockData.favorites)
        .padding(.vertical, Spacing.lg)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
