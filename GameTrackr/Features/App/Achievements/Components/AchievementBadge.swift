import SwiftUI

private enum Constants {
    static let defaultSize: CGFloat = 44
    static let borderWidth: CGFloat = 1
    static let iconScale: CGFloat = 0.46
    static let unlockedFillAlpha = 0.18
    static let lockedFillAlpha = 0.06
    static let unlockedBorderAlpha = 0.55
    static let lockedBorderAlpha = 0.2
    static let lockedIconAlpha = 0.45
}

struct AchievementBadge: View {
    let achievement: Achievement
    var size: CGFloat = Constants.defaultSize

    private var tint: Color {
        achievement.isUnlocked ? achievement.tier.tint : Color.appTextSecondary
    }

    private var fillAlpha: Double {
        achievement.isUnlocked ? Constants.unlockedFillAlpha : Constants.lockedFillAlpha
    }

    private var borderAlpha: Double {
        achievement.isUnlocked ? Constants.unlockedBorderAlpha : Constants.lockedBorderAlpha
    }

    private var iconAlpha: Double {
        achievement.isUnlocked ? 1 : Constants.lockedIconAlpha
    }

    var body: some View {
        Circle()
            .fill(tint.opacity(fillAlpha))
            .frame(width: size, height: size)
            .overlay {
                AppIconView(
                    icon: achievement.isHidden ? .eyeSlash : achievement.tier.icon,
                    filled: achievement.isUnlocked,
                    size: size * Constants.iconScale
                )
                .foregroundStyle(tint.opacity(iconAlpha))
            }
            .overlay {
                Circle()
                    .stroke(tint.opacity(borderAlpha), lineWidth: Constants.borderWidth)
            }
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: Spacing.md) {
        ForEach(AchievementsMockData.games[3].achievements) { achievement in
            AchievementBadge(achievement: achievement)
        }
    }
    .padding(Spacing.md)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
