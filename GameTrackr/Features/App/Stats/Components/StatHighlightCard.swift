import SwiftUI

struct StatHighlightCard: View {
    let highlight: StatHighlight

    var body: some View {
        VStack(spacing: 6) {
            Text(highlight.label.uppercased())
                .font(.appLabel(12))
                .kerning(1.6)
                .foregroundStyle(Color.appTextSecondary)

            Text(highlight.value)
                .font(.appHeadline(40, weight: .heavy))
                .foregroundStyle(Color.appPrimary)
                .shadow(color: Color.appPrimary.opacity(0.45), radius: 16)

            Text(highlight.caption)
                .font(.appBody(13))
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.appOutline, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(highlight.label), \(highlight.value), \(highlight.caption)")
    }
}

#Preview {
    StatHighlightCard(highlight: StatsMockData.stats.highlights[0])
        .padding(20)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
