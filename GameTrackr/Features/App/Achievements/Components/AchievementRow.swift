import SwiftUI

private enum Constants {
    static let checkIconSize: CGFloat = 12
    static let lockedTierAlpha = 0.5
    static let titleSize: CGFloat = 15
    static let tierSize: CGFloat = 11
    static let detailSize: CGFloat = 13
    static let unlockedAtSize: CGFloat = 12
}

struct AchievementRow: View {
    let achievement: Achievement

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            AchievementBadge(achievement: achievement)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                    Text(achievement.displayTitle)
                        .font(.appLabel(Constants.titleSize))
                        .foregroundStyle(achievement.isUnlocked ? Color.appTextPrimary : Color.appTextSecondary)

                    Spacer(minLength: 0)

                    Text(achievement.tier.title)
                        .font(.appBody(Constants.tierSize))
                        .foregroundStyle(
                            achievement.tier.tint.opacity(achievement.isUnlocked ? 1 : Constants.lockedTierAlpha)
                        )
                }

                Text(achievement.displayDetail)
                    .font(.appBody(Constants.detailSize))
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                if let unlockedAt = achievement.unlockedAt {
                    HStack(spacing: Spacing.xxs) {
                        AppIconView(icon: .check, size: Constants.checkIconSize)
                        Text(unlockedAt)
                            .font(.appBody(Constants.unlockedAtSize))
                    }
                    .foregroundStyle(Color.appPrimary)
                    .padding(.top, Spacing.xxxs)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.md) {
        ForEach(AchievementsMockData.games[3].achievements) { achievement in
            AchievementRow(achievement: achievement)
        }
    }
    .padding(Spacing.lg)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
