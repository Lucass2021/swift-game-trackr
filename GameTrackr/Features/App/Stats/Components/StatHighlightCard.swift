import SwiftUI

private enum Constants {
    static let borderWidth: CGFloat = 1
    static let labelSize: CGFloat = 12
    static let labelLetterSpacing: CGFloat = 1.6
    static let valueSize: CGFloat = 40
    static let captionSize: CGFloat = 13
    static let glowAlpha = 0.45
    static let glowRadius: CGFloat = 16
}

struct StatHighlightCard: View {
    let highlight: StatHighlight

    var body: some View {
        VStack(spacing: Spacing.xxs) {
            Text(highlight.label.uppercased())
                .font(.appLabel(Constants.labelSize))
                .kerning(Constants.labelLetterSpacing)
                .foregroundStyle(Color.appTextSecondary)

            Text(highlight.value)
                .font(.appHeadline(Constants.valueSize, weight: .heavy))
                .foregroundStyle(Color.appPrimary)
                .shadow(color: Color.appPrimary.opacity(Constants.glowAlpha), radius: Constants.glowRadius)

            Text(highlight.caption)
                .font(.appBody(Constants.captionSize))
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .stroke(Color.appOutline, lineWidth: Constants.borderWidth)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(highlight.label), \(highlight.value), \(highlight.caption)")
    }
}

#Preview {
    StatHighlightCard(highlight: StatsMockData.stats.highlights[0])
        .padding(Spacing.lg)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
