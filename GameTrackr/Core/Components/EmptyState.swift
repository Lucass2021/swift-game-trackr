import SwiftUI

private enum Constants {
    static let tileSize: CGFloat = 120
    static let tileCornerRadius: CGFloat = 28
    static let glowBlurRadius: CGFloat = 34
    static let glowAlpha = 0.35
    static let iconSize: CGFloat = 56
    static let titleSize: CGFloat = 24
    static let messageSize: CGFloat = 15
}

struct EmptyState: View {
    let icon: AppIcon
    let title: String
    let message: String
    var actionTitle: String?
    var actionIcon: AppIcon?
    var onAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            AppIconView(icon: icon, size: Constants.iconSize)
                .foregroundStyle(Color.appPrimary)
                .frame(width: Constants.tileSize, height: Constants.tileSize)
                .background(
                    Color.appSurfaceCard,
                    in: RoundedRectangle(cornerRadius: Constants.tileCornerRadius, style: .continuous)
                )
                .glow(color: .appPrimary, blurRadius: Constants.glowBlurRadius, alpha: Constants.glowAlpha)
                .subtleBounce()

            Text(title)
                .font(.appHeadline(Constants.titleSize, weight: .heavy))
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, Spacing.xl)

            Text(message)
                .font(.appBody(Constants.messageSize))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, Spacing.xs)

            if let actionTitle, let onAction {
                PrimaryButton(title: actionTitle, icon: actionIcon, action: onAction)
                    .padding(.top, Spacing.xl)
            }
        }
        .padding(.horizontal, Spacing.xxl)
        .padding(.vertical, Spacing.xxxl)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EmptyState(
        icon: .devices,
        title: "No setup yet",
        message: "Add your battle station, retro corner or handheld gear so other players can see how you play.",
        actionTitle: "Add your first setup",
        onAction: {}
    )
    .frame(maxHeight: .infinity)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
