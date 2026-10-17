import SwiftUI

private enum Constants {
    static let circleSize: CGFloat = 50
    static let circleIconSize: CGFloat = 20
    static let borderWidth: CGFloat = 1
}

struct CommunityDetailActions: View {
    let isJoined: Bool
    let isOwner: Bool
    let shareText: String
    let onJoin: () -> Void

    var body: some View {
        HStack(spacing: Spacing.sm) {
            JoinButton(isJoined: isJoined, expanded: true, isEnabled: !isOwner, action: onJoin)

            Button {} label: {
                circle(icon: .notifications)
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Community notifications")

            ShareLink(item: shareText) {
                circle(icon: .share)
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Share community")
        }
    }

    private func circle(icon: AppIcon) -> some View {
        AppIconView(icon: icon, size: Constants.circleIconSize)
            .foregroundStyle(Color.appTextPrimary)
            .frame(width: Constants.circleSize, height: Constants.circleSize)
            .background(Circle().stroke(Color.appOutline, lineWidth: Constants.borderWidth))
            .contentShape(Circle())
    }
}

#Preview {
    CommunityDetailActions(isJoined: false, isOwner: false, shareText: "", onJoin: {})
        .padding(Spacing.lg)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
