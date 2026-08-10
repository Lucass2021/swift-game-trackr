import SwiftUI

struct LibraryEntryRow: View {
    let entry: LibraryEntry
    var onFavorite: (() -> Void)?

    var body: some View {
        HStack(spacing: 14) {
            GameCoverArt(start: entry.coverStart, end: entry.coverEnd, width: 62, height: 82)

            VStack(alignment: .leading, spacing: 8) {
                Text(entry.title)
                    .font(.appLabel(18))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)

                HStack(spacing: 10) {
                    LibraryStatusBadge(status: entry.status)
                    StarRatingView(rating: entry.rating)
                }
            }

            Spacer(minLength: 8)

            VStack(spacing: 10) {
                if let onFavorite {
                    Button(action: onFavorite) {
                        AppIconView(icon: .like, filled: entry.isFavorite, size: 18)
                            .foregroundStyle(entry.isFavorite ? Color.appPrimary : Color.appTextSecondary)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PressableButtonStyle())
                    .accessibilityLabel(entry.isFavorite ? "Remove from favorites" : "Add to favorites")
                }

                Text("\(entry.hours)h")
                    .font(.appLabel(15))
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.appOutline, lineWidth: 1))
    }
}

#Preview {
    VStack(spacing: 14) {
        LibraryEntryRow(entry: LibraryMockData.entries[0])
        LibraryEntryRow(entry: LibraryMockData.entries[2])
    }
    .padding(20)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
