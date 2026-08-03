import SwiftUI

struct GameAchievementsRow: View {
    let game: GameAchievements

    var body: some View {
        HStack(spacing: 14) {
            GameCoverArt(start: game.coverStart, end: game.coverEnd, width: 56, height: 74)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(game.title)
                            .font(.appLabel(16))
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        Text(game.platform)
                            .font(.appBody(12))
                            .foregroundStyle(Color.appTextSecondary)
                    }

                    Spacer(minLength: 0)

                    if game.hasPlatinum {
                        AppIconView(icon: .trophy, filled: true, size: 18)
                            .foregroundStyle(Color.appSecondary)
                            .accessibilityLabel("Platinum earned")
                    }
                }

                progressBar

                HStack {
                    Text("\(game.unlockedCount) of \(game.total)")
                        .font(.appBody(12))
                        .foregroundStyle(Color.appTextSecondary)

                    Spacer()

                    Text("\(game.percent)%")
                        .font(.appLabel(12))
                        .foregroundStyle(game.isComplete ? Color.appPrimary : Color.appTextSecondary)
                        .monospacedDigit()
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.appOutline, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.appOutline)

                Capsule()
                    .fill(game.isComplete ? Color.appPrimary : Color.appSecondary.opacity(0.8))
                    .frame(width: proxy.size.width * game.fraction)
            }
        }
        .frame(height: 6)
    }
}

#Preview {
    VStack(spacing: 14) {
        ForEach(AchievementsMockData.games.prefix(3)) { game in
            GameAchievementsRow(game: game)
        }
    }
    .padding(20)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
