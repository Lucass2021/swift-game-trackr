import SwiftUI

struct AchievementRow: View {
    let achievement: Achievement

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            AchievementBadge(achievement: achievement)

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(achievement.displayTitle)
                        .font(.appLabel(15))
                        .foregroundStyle(achievement.isUnlocked ? Color.appTextPrimary : Color.appTextSecondary)

                    Spacer(minLength: 0)

                    Text(achievement.tier.title)
                        .font(.appBody(11))
                        .foregroundStyle(achievement.tier.tint.opacity(achievement.isUnlocked ? 1 : 0.5))
                }

                Text(achievement.displayDetail)
                    .font(.appBody(13))
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                if let unlockedAt = achievement.unlockedAt {
                    HStack(spacing: 6) {
                        AppIconView(icon: .check, size: 12)
                        Text(unlockedAt)
                            .font(.appBody(12))
                    }
                    .foregroundStyle(Color.appPrimary)
                    .padding(.top, 2)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 18) {
        ForEach(AchievementsMockData.games[3].achievements) { achievement in
            AchievementRow(achievement: achievement)
        }
    }
    .padding(20)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
