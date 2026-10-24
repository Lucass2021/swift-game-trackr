import SwiftUI

struct SettingsNotificationsSection: View {
    let settings: NotificationSettings?
    let hasError: Bool
    let onToggle: (NotificationSetting, Bool) -> Void
    let onRetry: () -> Void

    var body: some View {
        SettingsSection(title: "Notifications") {
            if let settings {
                ForEach(Array(NotificationSetting.allCases.enumerated()), id: \.element) { index, setting in
                    SettingsToggleRow(
                        icon: setting.icon,
                        title: setting.title,
                        isOn: Binding(get: { settings.isEnabled(setting) }, set: { onToggle(setting, $0) })
                    )
                    if index < NotificationSetting.allCases.count - 1 {
                        SettingsDivider()
                    }
                }
            } else if hasError {
                messageRow("Couldn't load notification settings.") {
                    Button("Try again", action: onRetry)
                        .font(.appLabel(Constants.messageSize))
                        .foregroundStyle(Color.appPrimary)
                }
            } else {
                messageRow("Loading notification settings…") { EmptyView() }
            }
        }
    }

    private func messageRow(_ text: String, @ViewBuilder action: () -> some View) -> some View {
        HStack(spacing: Spacing.sm) {
            Text(text)
                .font(.appBody(Constants.messageSize))
                .foregroundStyle(Color.appTextSecondary)
            Spacer()
            action()
        }
        .padding(Spacing.md)
    }
}

private extension NotificationSetting {
    var icon: AppIcon {
        switch self {
        case .push: .notifications
        case .friendRequests: .addFriend
        case .communityReplies: .comment
        }
    }

    var title: String {
        switch self {
        case .push: "Push notifications"
        case .friendRequests: "Friend requests"
        case .communityReplies: "Community replies"
        }
    }
}

private enum Constants {
    static let messageSize: CGFloat = 14
}

#Preview {
    VStack(spacing: Spacing.xl) {
        SettingsNotificationsSection(
            settings: NotificationSettings(friendRequests: false),
            hasError: false,
            onToggle: { _, _ in },
            onRetry: {}
        )
        SettingsNotificationsSection(settings: nil, hasError: true, onToggle: { _, _ in }, onRetry: {})
    }
    .padding()
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
