import SwiftUI

private enum Constants {
    static let barHeight: CGFloat = 7
    static let minBarWidth: CGFloat = 8
    static let labelSize: CGFloat = 12
    static let labelLetterSpacing: CGFloat = 0.8
}

struct StatBarList: View {
    let bars: [StatBar]

    var body: some View {
        VStack(spacing: Spacing.md) {
            ForEach(bars) { bar in
                row(bar)
            }
        }
    }

    private func row(_ bar: StatBar) -> some View {
        VStack(spacing: Spacing.xs) {
            HStack {
                Text(bar.label.uppercased())
                    .font(.appLabel(Constants.labelSize))
                    .kerning(Constants.labelLetterSpacing)
                    .foregroundStyle(Color.appTextPrimary)

                Spacer(minLength: Spacing.sm)

                Text(bar.value.uppercased())
                    .font(.appLabel(Constants.labelSize))
                    .kerning(Constants.labelLetterSpacing)
                    .foregroundStyle(Color.appTextSecondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.appOutline)

                    Capsule()
                        .fill(bar.tint)
                        .frame(width: max(geo.size.width * min(max(bar.fraction, 0), 1), Constants.minBarWidth))
                }
            }
            .frame(height: Constants.barHeight)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(bar.label), \(bar.value)")
    }
}

#Preview {
    StatBarList(bars: StatsMockData.stats.platforms)
        .padding(Spacing.lg)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
