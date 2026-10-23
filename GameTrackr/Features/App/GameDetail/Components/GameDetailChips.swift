import SwiftUI

private enum Constants {
    static let textSize: CGFloat = 13
    static let borderWidth: CGFloat = 1
    static let star = "\u{2605}"
    static let genreFillAlpha = 0.12
    static let genreBorderAlpha = 0.45
}

struct GameInfoChip: View {
    enum Style {
        case plain
        case rating
    }

    let text: String
    var style: Style = .plain

    private var color: Color {
        style == .rating ? .appPrimary : .appTextSecondary
    }

    var body: some View {
        HStack(spacing: Spacing.xxs) {
            if style == .rating {
                Text(Constants.star)
                    .font(.system(size: Constants.textSize))
                    .foregroundStyle(Color.appPrimary)
            }
            Text(text)
                .font(.appLabel(Constants.textSize))
                .foregroundStyle(color)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                .stroke(Color.appOutline, lineWidth: Constants.borderWidth)
        )
    }
}

struct GameGenreChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.appLabel(Constants.textSize))
            .foregroundStyle(Color.appPrimary)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(Capsule().fill(Color.appPrimary.opacity(Constants.genreFillAlpha)))
            .overlay(
                Capsule().stroke(Color.appPrimary.opacity(Constants.genreBorderAlpha), lineWidth: Constants.borderWidth)
            )
    }
}

#Preview {
    HStack(spacing: Spacing.xs) {
        GameInfoChip(text: "2024")
        GameInfoChip(text: "4.8", style: .rating)
        GameGenreChip(text: "Action RPG")
    }
    .padding(Spacing.md)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
