import SwiftUI

struct GameAchievementsView: View {
    let game: GameAchievements

    @Environment(\.dismiss) private var dismiss

    private var unlocked: [Achievement] {
        game.achievements.filter(\.isUnlocked)
    }

    private var locked: [Achievement] {
        game.achievements.filter { !$0.isUnlocked }
    }

    var body: some View {
        VStack(spacing: 0) {
            StatsTopBar(
                title: "Achievements",
                subtitle: game.title,
                onBack: { dismiss() }
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    header

                    if !unlocked.isEmpty {
                        StatsSectionCard(title: "Unlocked", icon: .success) {
                            list(unlocked)
                        }
                    }

                    if !locked.isEmpty {
                        StatsSectionCard(title: "Locked", icon: .eyeSlash) {
                            list(locked)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }

    private var header: some View {
        HStack(spacing: 16) {
            GameCoverArt(start: game.coverStart, end: game.coverEnd, width: 72, height: 96)

            VStack(alignment: .leading, spacing: 8) {
                Text(game.title)
                    .font(.appHeadline(20))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(2)

                Text(game.platform)
                    .font(.appBody(13))
                    .foregroundStyle(Color.appTextSecondary)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(game.unlockedCount)/\(game.total)")
                        .font(.appHeadline(18))
                        .foregroundStyle(Color.appPrimary)
                        .monospacedDigit()

                    Text("· \(game.percent)%")
                        .font(.appBody(13))
                        .foregroundStyle(Color.appTextSecondary)

                    if game.hasPlatinum {
                        AppIconView(icon: .trophy, filled: true, size: 16)
                            .foregroundStyle(Color.appSecondary)
                            .accessibilityLabel("Platinum earned")
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.appOutline, lineWidth: 1)
        )
    }

    private func list(_ achievements: [Achievement]) -> some View {
        VStack(spacing: 18) {
            ForEach(achievements) { achievement in
                AchievementRow(achievement: achievement)
            }
        }
    }
}

#Preview("Platinum") {
    NavigationStack {
        GameAchievementsView(game: AchievementsMockData.games[0])
    }
    .preferredColorScheme(.dark)
}

#Preview("In progress") {
    NavigationStack {
        GameAchievementsView(game: AchievementsMockData.games[4])
    }
    .preferredColorScheme(.dark)
}
