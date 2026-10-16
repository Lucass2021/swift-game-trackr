import SwiftUI

private enum Constants {
    static let borderWidth: CGFloat = 1
    static let iconSize: CGFloat = 22
    static let titleSize: CGFloat = 22
}

struct StatsSectionCard<Content: View>: View {
    let title: String
    let icon: AppIcon
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(alignment: .top) {
                Text(title)
                    .font(.appHeadline(Constants.titleSize, weight: .heavy))
                    .foregroundStyle(Color.appTextPrimary)

                Spacer(minLength: Spacing.sm)

                AppIconView(icon: icon, size: Constants.iconSize)
                    .foregroundStyle(Color.appSecondary)
            }

            content
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .stroke(Color.appOutline, lineWidth: Constants.borderWidth)
        )
    }
}

#Preview {
    StatsSectionCard(title: "By status", icon: .chart) {
        Text("Content")
            .foregroundStyle(Color.appTextSecondary)
    }
    .padding(Spacing.lg)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
