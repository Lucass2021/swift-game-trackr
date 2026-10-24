import SwiftUI

struct GroupedSection<Content: View>: View {
    let title: String?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            if let title {
                Text(title)
                    .font(.appLabel(Constants.titleSize))
                    .foregroundStyle(Color.appTextSecondary)
                    .textCase(.uppercase)
                    .padding(.leading, Spacing.xxs)
            }

            VStack(spacing: 0) {
                content
            }
            .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: Radius.lg))
        }
    }
}

struct GroupedDivider: View {
    var body: some View {
        Divider()
            .overlay(Color.appOutline)
            .padding(.leading, Constants.dividerInset)
    }
}

private enum Constants {
    static let titleSize: CGFloat = 13
    static let dividerInset = Spacing.md + GroupedRowMetrics.iconBoxWidth + Spacing.sm
}

#Preview {
    GroupedSection(title: "Account") {
        GroupedNavRow(icon: .shieldCheck, title: "Change password") {}
        GroupedDivider()
        GroupedDestructiveRow(icon: .close, title: "Delete account", isLoading: false) {}
    }
    .padding()
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
