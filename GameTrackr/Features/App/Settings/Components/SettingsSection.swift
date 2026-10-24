import SwiftUI

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(.appLabel(Constants.titleSize))
                .foregroundStyle(Color.appTextSecondary)
                .textCase(.uppercase)
                .padding(.leading, Spacing.xxs)

            VStack(spacing: 0) {
                content
            }
            .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: Radius.lg))
        }
    }
}

struct SettingsDivider: View {
    var body: some View {
        Divider()
            .overlay(Color.appOutline)
            .padding(.leading, Constants.dividerInset)
    }
}

private enum Constants {
    static let titleSize: CGFloat = 13
    static let dividerInset = Spacing.md + SettingsRowMetrics.iconBoxWidth + Spacing.sm
}

#Preview {
    SettingsSection(title: "Account") {
        SettingsNavRow(icon: .shieldCheck, title: "Change password") {}
        SettingsDivider()
        SettingsDestructiveRow(icon: .close, title: "Delete account", isLoading: false) {}
    }
    .padding()
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
