import SwiftUI

enum SettingsRowMetrics {
    static let iconBoxWidth: CGFloat = 24
}

private enum Constants {
    static let iconSize: CGFloat = 20
    static let chevronSize: CGFloat = 16
    static let titleSize: CGFloat = 16
    static let progressSize: CGFloat = 16
}

struct SettingsToggleRow: View {
    let icon: AppIcon
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        SettingsRowLayout(icon: icon, title: title, tint: .appPrimary, titleColor: .appTextPrimary) {
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.appPrimary)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }
}

struct SettingsNavRow: View {
    let icon: AppIcon
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            SettingsRowLayout(icon: icon, title: title, tint: .appPrimary, titleColor: .appTextPrimary) {
                AppIconView(icon: .forward, size: Constants.chevronSize)
                    .foregroundStyle(Color.appTextSecondary)
            }
            .padding(Spacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
    }
}

struct SettingsDestructiveRow: View {
    let icon: AppIcon
    let title: String
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            SettingsRowLayout(icon: icon, title: title, tint: .appTertiary, titleColor: .appTertiary) {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .tint(Color.appTertiary)
                        .frame(width: Constants.progressSize, height: Constants.progressSize)
                }
            }
            .padding(Spacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
    }
}

private struct SettingsRowLayout<Trailing: View>: View {
    let icon: AppIcon
    let title: String
    let tint: Color
    let titleColor: Color
    @ViewBuilder let trailing: Trailing

    var body: some View {
        HStack(spacing: Spacing.sm) {
            AppIconView(icon: icon, size: Constants.iconSize)
                .foregroundStyle(tint)
                .frame(width: SettingsRowMetrics.iconBoxWidth)

            Text(title)
                .font(.appLabel(Constants.titleSize))
                .foregroundStyle(titleColor)

            Spacer()

            trailing
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        SettingsToggleRow(icon: .notifications, title: "Push notifications", isOn: .constant(true))
        SettingsNavRow(icon: .shieldCheck, title: "Change password") {}
        SettingsDestructiveRow(icon: .close, title: "Delete account", isLoading: true) {}
    }
    .background(Color.appSurfaceCard)
    .preferredColorScheme(.dark)
}
