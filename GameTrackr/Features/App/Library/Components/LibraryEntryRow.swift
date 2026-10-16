import SwiftUI

private enum Constants {
    static let borderWidth: CGFloat = 1
    static let coverWidth: CGFloat = 62
    static let coverHeight: CGFloat = 82
    static let favoriteIconSize: CGFloat = 18
    static let titleSize: CGFloat = 18
    static let hoursSize: CGFloat = 15
}

struct LibraryEntryRow: View {
    let entry: LibraryEntry
    var onFavorite: (() -> Void)?

    var body: some View {
        HStack(spacing: Spacing.sm) {
            GameCoverArt(
                start: entry.coverStart,
                end: entry.coverEnd,
                width: Constants.coverWidth,
                height: Constants.coverHeight
            )

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(entry.title)
                    .font(.appLabel(Constants.titleSize))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)

                HStack(spacing: Spacing.xs) {
                    LibraryStatusBadge(status: entry.status)
                    StarRatingView(rating: entry.rating)
                }
            }

            Spacer(minLength: Spacing.xs)

            VStack(spacing: Spacing.xs) {
                if let onFavorite {
                    Button(action: onFavorite) {
                        AppIconView(icon: .like, filled: entry.isFavorite, size: Constants.favoriteIconSize)
                            .foregroundStyle(entry.isFavorite ? Color.appPrimary : Color.appTextSecondary)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PressableButtonStyle())
                    .accessibilityLabel(entry.isFavorite ? "Remove from favorites" : "Add to favorites")
                }

                Text("\(entry.hours)h")
                    .font(.appLabel(Constants.hoursSize))
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .padding(Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous).stroke(
            Color.appOutline,
            lineWidth: Constants.borderWidth
        ))
    }
}

#Preview {
    VStack(spacing: Spacing.sm) {
        LibraryEntryRow(entry: LibraryMockData.entries[0])
        LibraryEntryRow(entry: LibraryMockData.entries[2])
    }
    .padding(Spacing.lg)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
