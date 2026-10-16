import SwiftUI

private enum Constants {
    static let borderWidth: CGFloat = 1
    static let coverWidth: CGFloat = 56
    static let coverHeight: CGFloat = 74
    static let platinumIconSize: CGFloat = 18
    static let barHeight: CGFloat = 6
    static let inProgressAlpha = 0.8
    static let titleSize: CGFloat = 16
    static let detailSize: CGFloat = 12
}

struct GameAchievementsRow: View {
    let game: GameAchievements

    var body: some View {
        HStack(spacing: Spacing.sm) {
            GameCoverArt(
                start: game.coverStart,
                end: game.coverEnd,
                width: Constants.coverWidth,
                height: Constants.coverHeight
            )

            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack(alignment: .top, spacing: Spacing.xs) {
                    VStack(alignment: .leading, spacing: Spacing.xxxs) {
                        Text(game.title)
                            .font(.appLabel(Constants.titleSize))
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        Text(game.platform)
                            .font(.appBody(Constants.detailSize))
                            .foregroundStyle(Color.appTextSecondary)
                    }

                    Spacer(minLength: 0)

                    if game.hasPlatinum {
                        AppIconView(icon: .trophy, filled: true, size: Constants.platinumIconSize)
                            .foregroundStyle(Color.appSecondary)
                            .accessibilityLabel("Platinum earned")
                    }
                }

                progressBar

                HStack {
                    Text("\(game.unlockedCount) of \(game.total)")
                        .font(.appBody(Constants.detailSize))
                        .foregroundStyle(Color.appTextSecondary)

                    Spacer()

                    Text("\(game.percent)%")
                        .font(.appLabel(Constants.detailSize))
                        .foregroundStyle(game.isComplete ? Color.appPrimary : Color.appTextSecondary)
                        .monospacedDigit()
                }
            }
        }
        .padding(Spacing.sm)
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
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.appOutline)

                Capsule()
                    .fill(game.isComplete ? Color.appPrimary : Color.appSecondary.opacity(Constants.inProgressAlpha))
                    .frame(width: proxy.size.width * game.fraction)
            }
        }
        .frame(height: Constants.barHeight)
    }
}

#Preview {
    VStack(spacing: Spacing.sm) {
        ForEach(AchievementsMockData.games.prefix(3)) { game in
            GameAchievementsRow(game: game)
        }
    }
    .padding(Spacing.lg)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
