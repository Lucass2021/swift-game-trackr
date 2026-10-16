import SwiftUI

private enum Constants {
    static let borderWidth: CGFloat = 1
    static let barHeight: CGFloat = 10
    static let statIconSize: CGFloat = 16
    static let countSize: CGFloat = 34
    static let totalSize: CGFloat = 15
    static let percentSize: CGFloat = 20
    static let statValueSize: CGFloat = 15
    static let statLabelSize: CGFloat = 11
}

struct AchievementsSummaryCard: View {
    let summary: AchievementsSummary

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                Text("\(summary.unlockedCount)")
                    .font(.appHeadline(Constants.countSize, weight: .heavy))
                    .foregroundStyle(Color.appPrimary)

                Text("of \(summary.total) unlocked")
                    .font(.appBody(Constants.totalSize))
                    .foregroundStyle(Color.appTextSecondary)

                Spacer(minLength: Spacing.xs)

                Text("\(summary.percent)%")
                    .font(.appHeadline(Constants.percentSize))
                    .foregroundStyle(Color.appTextPrimary)
                    .monospacedDigit()
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.appOutline)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.appPrimary, .appSecondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: proxy.size.width * summary.fraction)
                }
            }
            .frame(height: Constants.barHeight)

            HStack(spacing: Spacing.lg) {
                miniStat(icon: .trophy, value: "\(summary.platinumCount)", label: "Platinums")
                miniStat(icon: .success, value: "\(summary.completedCount)", label: "Completed")
                miniStat(icon: .brand, value: "\(summary.gameCount)", label: "Games")
            }
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .stroke(Color.appOutline, lineWidth: Constants.borderWidth)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(summary.unlockedCount) of \(summary.total) achievements unlocked")
    }

    private func miniStat(icon: AppIcon, value: String, label: String) -> some View {
        HStack(spacing: Spacing.xs) {
            AppIconView(icon: icon, size: Constants.statIconSize)
                .foregroundStyle(Color.appSecondary)

            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.appLabel(Constants.statValueSize))
                    .foregroundStyle(Color.appTextPrimary)

                Text(label)
                    .font(.appBody(Constants.statLabelSize))
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
    }
}

#Preview {
    AchievementsSummaryCard(summary: AchievementsSummary(
        unlockedCount: 42,
        total: 60,
        platinumCount: 2,
        completedCount: 3,
        gameCount: 6
    ))
    .padding(Spacing.lg)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
