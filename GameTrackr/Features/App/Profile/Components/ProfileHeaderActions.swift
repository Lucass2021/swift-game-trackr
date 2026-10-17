import SwiftUI

private enum Constants {
    static let buttonHeight: CGFloat = 46
    static let borderWidth: CGFloat = 1
    static let pillIconSize: CGFloat = 18
    static let circleIconSize: CGFloat = 20
    static let labelSize: CGFloat = 15
}

struct ProfileHeaderActions: View {
    let mode: ProfileHeaderMode
    var isGuest = false
    var shareText = ""
    var onEdit: () -> Void = {}
    var onAddFriend: () -> Void = {}
    var onMessage: () -> Void = {}

    var body: some View {
        HStack(spacing: Spacing.sm) {
            switch mode {
            case .own:
                pill(icon: .editProfile, title: "Edit profile", isPrimary: true, action: onEdit)
            case let .other(isFriend):
                if !isGuest {
                    pill(
                        icon: isFriend ? .check : .addFriend,
                        title: isFriend ? "Friends" : "Add friend",
                        isPrimary: !isFriend,
                        action: onAddFriend
                    )
                    circleAction(icon: .envelope, label: "Send message", action: onMessage)
                }
            }

            shareLink
        }
    }

    private func pill(icon: AppIcon, title: String, isPrimary: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                AppIconView(icon: icon, size: Constants.pillIconSize)
                Text(title)
                    .font(.appLabel(Constants.labelSize))
            }
            .foregroundStyle(isPrimary ? Color.appOnPrimary : Color.appTextPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: Constants.buttonHeight)
            .background {
                if isPrimary {
                    Capsule().fill(Color.appPrimary)
                } else {
                    Capsule().stroke(Color.appOutline, lineWidth: Constants.borderWidth)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func circleAction(icon: AppIcon, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            circle(icon: icon)
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(label)
    }

    private var shareLink: some View {
        ShareLink(item: shareText) {
            circle(icon: .share)
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel("Share profile")
    }

    private func circle(icon: AppIcon) -> some View {
        AppIconView(icon: icon, size: Constants.circleIconSize)
            .foregroundStyle(Color.appTextPrimary)
            .frame(width: Constants.buttonHeight, height: Constants.buttonHeight)
            .background(Circle().stroke(Color.appOutline, lineWidth: Constants.borderWidth))
            .contentShape(Circle())
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        ProfileHeaderActions(mode: .own)
        ProfileHeaderActions(mode: .other(isFriend: false))
        ProfileHeaderActions(mode: .other(isFriend: true))
    }
    .padding(Spacing.lg)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
