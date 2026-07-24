import SwiftUI

struct StatBarList: View {
    let bars: [StatBar]

    var body: some View {
        VStack(spacing: 16) {
            ForEach(bars) { bar in
                row(bar)
            }
        }
    }

    private func row(_ bar: StatBar) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(bar.label.uppercased())
                    .font(.appLabel(12))
                    .kerning(0.8)
                    .foregroundStyle(Color.appTextPrimary)

                Spacer(minLength: 12)

                Text(bar.value.uppercased())
                    .font(.appLabel(12))
                    .kerning(0.8)
                    .foregroundStyle(Color.appTextSecondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.appOutline)

                    Capsule()
                        .fill(bar.tint)
                        .frame(width: max(geo.size.width * bar.fraction, 8))
                }
            }
            .frame(height: 7)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(bar.label), \(bar.value)")
    }
}

#Preview {
    StatBarList(bars: StatsMockData.stats.platforms)
        .padding(20)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
