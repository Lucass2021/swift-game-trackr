import SwiftUI

struct AchievementsSummaryCard: View {
    let games: [GameAchievements]

    private var percent: Int {
        Int((games.unlockedFraction * 100).rounded())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(games.unlockedTotal)")
                    .font(.appHeadline(34, weight: .heavy))
                    .foregroundStyle(Color.appPrimary)

                Text("of \(games.achievementTotal) unlocked")
                    .font(.appBody(15))
                    .foregroundStyle(Color.appTextSecondary)

                Spacer(minLength: 8)

                Text("\(percent)%")
                    .font(.appHeadline(20))
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
                        .frame(width: proxy.size.width * games.unlockedFraction)
                }
            }
            .frame(height: 10)

            HStack(spacing: 22) {
                miniStat(icon: .trophy, value: "\(games.platinumCount)", label: "Platinums")
                miniStat(icon: .success, value: "\(games.completedCount)", label: "Completed")
                miniStat(icon: .brand, value: "\(games.count)", label: "Games")
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.appOutline, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(games.unlockedTotal) of \(games.achievementTotal) achievements unlocked")
    }

    private func miniStat(icon: AppIcon, value: String, label: String) -> some View {
        HStack(spacing: 8) {
            AppIconView(icon: icon, size: 16)
                .foregroundStyle(Color.appSecondary)

            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.appLabel(15))
                    .foregroundStyle(Color.appTextPrimary)

                Text(label)
                    .font(.appBody(11))
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
    }
}

#Preview {
    AchievementsSummaryCard(games: AchievementsMockData.games)
        .padding(20)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
