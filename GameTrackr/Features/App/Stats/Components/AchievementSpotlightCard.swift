import SwiftUI

private enum Constants {
    static let trophySize: CGFloat = 140
    static let trophyOffsetX: CGFloat = 30
    static let trophyOffsetY: CGFloat = -20
    static let trophyAlpha = 0.12
    static let overlayAlpha = 0.45
    static let messageAlpha = 0.85
    static let actionHeight: CGFloat = 44
    static let titleSize: CGFloat = 24
    static let messageSize: CGFloat = 15
    static let actionTextSize: CGFloat = 15
}

struct AchievementSpotlightCard: View {
    let spotlight: AchievementSpotlight
    var onAction: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(spotlight.title)
                .font(.appHeadline(Constants.titleSize, weight: .heavy))
                .foregroundStyle(Color.appTextPrimary)

            Text(spotlight.message)
                .font(.appBody(Constants.messageSize))
                .foregroundStyle(Color.appTextPrimary.opacity(Constants.messageAlpha))
                .fixedSize(horizontal: false, vertical: true)

            Button(action: onAction) {
                Text(spotlight.actionTitle)
                    .font(.appLabel(Constants.actionTextSize))
                    .foregroundStyle(Color.appOnPrimary)
                    .padding(.horizontal, Spacing.xl)
                    .frame(height: Constants.actionHeight)
                    .background(Capsule().fill(Color.appPrimary))
                    .contentShape(Capsule())
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.top, Spacing.xxs)
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
    }

    private var background: some View {
        LinearGradient(
            colors: [.coverIndigoStart, .coverCyanStart, .coverIndigoEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(Color.appBackground.opacity(Constants.overlayAlpha))
        .overlay(alignment: .topTrailing) {
            AppIconView(icon: .trophy, size: Constants.trophySize)
                .foregroundStyle(Color.appPrimary.opacity(Constants.trophyAlpha))
                .offset(x: Constants.trophyOffsetX, y: Constants.trophyOffsetY)
        }
    }
}

#Preview {
    AchievementSpotlightCard(spotlight: StatsMockData.stats.spotlight)
        .padding(Spacing.lg)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
