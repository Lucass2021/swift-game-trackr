import SwiftUI

struct GameAchievementsView: View {
    let gameId: Int
    var repository: AchievementsRepository = FakeAchievementsRepository()

    @Environment(\.dismiss) private var dismiss

    @State private var game: GameAchievements?

    var body: some View {
        VStack(spacing: 0) {
            StatsTopBar(
                title: "Achievements",
                subtitle: game?.title,
                onBack: { dismiss() }
            )

            if let game {
                content(game)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .task(id: gameId) {
            guard game?.id != gameId else { return }
            game = nil
            game = try? await repository.fetchGameAchievements(id: gameId)
        }
    }

    private func content(_ game: GameAchievements) -> some View {
        let unlocked = game.achievements.filter(\.isUnlocked)
        let locked = game.achievements.filter { !$0.isUnlocked }

        return ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                header(game)

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

    private func header(_ game: GameAchievements) -> some View {
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
        GameAchievementsView(gameId: AchievementsMockData.games[0].id)
    }
    .preferredColorScheme(.dark)
}

#Preview("In progress") {
    NavigationStack {
        GameAchievementsView(gameId: AchievementsMockData.games[4].id)
    }
    .preferredColorScheme(.dark)
}
