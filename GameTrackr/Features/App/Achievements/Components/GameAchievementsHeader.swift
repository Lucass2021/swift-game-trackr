import SwiftUI

private enum Constants {
    static let borderWidth: CGFloat = 1
    static let coverWidth: CGFloat = 72
    static let coverHeight: CGFloat = 96
    static let platinumIconSize: CGFloat = 16
    static let titleSize: CGFloat = 20
    static let ratioSize: CGFloat = 18
    static let detailSize: CGFloat = 13
}

struct GameAchievementsHeader: View {
    let game: GameAchievements

    var body: some View {
        HStack(spacing: Spacing.md) {
            GameCoverArt(
                start: game.coverStart,
                end: game.coverEnd,
                width: Constants.coverWidth,
                height: Constants.coverHeight
            )

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(game.title)
                    .font(.appHeadline(Constants.titleSize))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(2)

                Text(game.platform)
                    .font(.appBody(Constants.detailSize))
                    .foregroundStyle(Color.appTextSecondary)

                HStack(alignment: .firstTextBaseline, spacing: Spacing.xxs) {
                    Text("\(game.unlockedCount)/\(game.total)")
                        .font(.appHeadline(Constants.ratioSize))
                        .foregroundStyle(Color.appPrimary)
                        .monospacedDigit()

                    Text("· \(game.percent)%")
                        .font(.appBody(Constants.detailSize))
                        .foregroundStyle(Color.appTextSecondary)

                    if game.hasPlatinum {
                        AppIconView(icon: .trophy, filled: true, size: Constants.platinumIconSize)
                            .foregroundStyle(Color.appSecondary)
                            .accessibilityLabel("Platinum earned")
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .stroke(Color.appOutline, lineWidth: Constants.borderWidth)
        )
    }
}

#Preview {
    GameAchievementsHeader(game: AchievementsMockData.games[0])
        .padding(Spacing.lg)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
