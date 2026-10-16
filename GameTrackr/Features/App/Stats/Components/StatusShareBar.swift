import SwiftUI

private enum Constants {
    static let barHeight: CGFloat = 26
    static let dotSize: CGFloat = 8
    static let percentSize: CGFloat = 13
    static let labelSize: CGFloat = 12
}

struct StatusShareBar: View {
    let shares: [StatusShare]

    private var total: Double {
        max(Double(shares.reduce(0) { $0 + $1.percent }), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            GeometryReader { geo in
                HStack(spacing: 0) {
                    ForEach(shares) { share in
                        Rectangle()
                            .fill(share.status.barTint)
                            .frame(width: geo.size.width * Double(share.percent) / total)
                    }
                }
            }
            .frame(height: Constants.barHeight)
            .clipShape(Capsule())

            HStack(alignment: .top, spacing: Spacing.md) {
                ForEach(shares) { share in
                    legend(share)
                }
                Spacer(minLength: 0)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func legend(_ share: StatusShare) -> some View {
        HStack(alignment: .top, spacing: Spacing.xs) {
            Circle()
                .fill(share.status.barTint)
                .frame(width: Constants.dotSize, height: Constants.dotSize)
                .padding(.top, Spacing.xxs)

            VStack(alignment: .leading, spacing: Spacing.xxxs) {
                Text("\(share.percent)%")
                    .font(.appLabel(Constants.percentSize))
                    .foregroundStyle(Color.appTextPrimary)
                Text(share.status.rawValue)
                    .font(.appBody(Constants.labelSize))
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
    }
}

#Preview {
    StatusShareBar(shares: StatsMockData.stats.statusShare)
        .padding(Spacing.lg)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
