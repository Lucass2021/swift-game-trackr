import SwiftUI

struct AchievementBadge: View {
    let achievement: Achievement
    var size: CGFloat = 44

    private var tint: Color {
        achievement.isUnlocked ? achievement.tier.tint : Color.appTextSecondary
    }

    var body: some View {
        Circle()
            .fill(tint.opacity(achievement.isUnlocked ? 0.18 : 0.06))
            .frame(width: size, height: size)
            .overlay {
                AppIconView(
                    icon: achievement.isHidden ? .eyeSlash : achievement.tier.icon,
                    filled: achievement.isUnlocked,
                    size: size * 0.46
                )
                .foregroundStyle(tint.opacity(achievement.isUnlocked ? 1 : 0.45))
            }
            .overlay {
                Circle()
                    .stroke(tint.opacity(achievement.isUnlocked ? 0.55 : 0.2), lineWidth: 1)
            }
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: 16) {
        ForEach(AchievementsMockData.games[3].achievements) { achievement in
            AchievementBadge(achievement: achievement)
        }
    }
    .padding()
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
