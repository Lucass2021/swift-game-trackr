import SwiftUI

struct GameInfoChip: View {
    enum Style {
        case plain
        case rating
    }

    let text: String
    var style: Style = .plain

    var body: some View {
        HStack(spacing: 5) {
            if style == .rating {
                Text("\u{2605}")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.appPrimary)
            }
            Text(text)
                .font(.appLabel(13))
                .foregroundStyle(style == .rating ? Color.appPrimary : Color.appTextSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.appOutline, lineWidth: 1)
        )
    }
}

struct GameGenreChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.appLabel(13))
            .foregroundStyle(Color.appPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule().fill(Color.appPrimary.opacity(0.12))
            )
            .overlay(
                Capsule().stroke(Color.appPrimary.opacity(0.45), lineWidth: 1)
            )
    }
}
