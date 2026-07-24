import SwiftUI

struct AchievementSpotlightCard: View {
    let spotlight: AchievementSpotlight
    var onAction: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(spotlight.title)
                .font(.appHeadline(24, weight: .heavy))
                .foregroundStyle(Color.appTextPrimary)

            Text(spotlight.message)
                .font(.appBody(15))
                .foregroundStyle(Color.appTextPrimary.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)

            Button(action: onAction) {
                Text(spotlight.actionTitle)
                    .font(.appLabel(15))
                    .foregroundStyle(Color.appOnPrimary)
                    .padding(.horizontal, 26)
                    .frame(height: 44)
                    .background(Capsule().fill(Color.appPrimary))
                    .contentShape(Capsule())
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.top, 4)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var background: some View {
        LinearGradient(
            colors: [.coverIndigoStart, .coverCyanStart, .coverIndigoEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(Color.appBackground.opacity(0.45))
        .overlay(alignment: .topTrailing) {
            AppIconView(icon: .trophy, size: 140)
                .foregroundStyle(Color.appPrimary.opacity(0.12))
                .offset(x: 30, y: -20)
        }
    }
}

#Preview {
    AchievementSpotlightCard(spotlight: StatsMockData.stats.spotlight)
        .padding(20)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
