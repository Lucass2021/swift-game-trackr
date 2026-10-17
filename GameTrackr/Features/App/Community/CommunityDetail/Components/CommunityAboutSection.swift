import SwiftUI

private enum Constants {
    static let borderWidth: CGFloat = 1
    static let iconSize: CGFloat = 18
    static let bodySize: CGFloat = 15
    static let noteSize: CGFloat = 13
}

struct CommunityAboutSection: View {
    let community: Community
    var isOwner = false
    var onDelete: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(community.description)
                .font(.appBody(Constants.bodySize))
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 0) {
                infoRow(icon: .community, label: "Category", value: "#\(community.category)")
                if let createdMonth = community.createdMonth {
                    Rectangle().fill(Color.appOutline).frame(height: Constants.borderWidth)
                    infoRow(icon: .calendar, label: "Created", value: createdMonth)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .fill(Color.appSurfaceCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .stroke(Color.appOutline, lineWidth: Constants.borderWidth)
            )

            if isOwner {
                Button(action: onDelete) {
                    HStack(spacing: Spacing.sm) {
                        AppIconView(icon: .trash, size: Constants.iconSize)
                            .foregroundStyle(Color.appTertiary)

                        Text("Delete community")
                            .font(.appLabel(Constants.bodySize))
                            .foregroundStyle(Color.appTertiary)

                        Spacer()
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.md)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                            .fill(Color.appSurfaceCard)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                            .stroke(Color.appOutline, lineWidth: Constants.borderWidth)
                    )
                    .contentShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
                }
                .buttonStyle(PressableButtonStyle())

                Text("Only you can see this — you created this community.")
                    .font(.appBody(Constants.noteSize))
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.xxs)
    }

    private func infoRow(icon: AppIcon, label: String, value: String) -> some View {
        HStack(spacing: Spacing.sm) {
            AppIconView(icon: icon, size: Constants.iconSize)
                .foregroundStyle(Color.appTextSecondary)

            Text(label)
                .font(.appBody(Constants.bodySize))
                .foregroundStyle(Color.appTextSecondary)

            Spacer()

            Text(value)
                .font(.appLabel(Constants.bodySize))
                .foregroundStyle(Color.appTextPrimary)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.md)
    }
}

#Preview {
    CommunityAboutSection(community: CommunityMockData.detailCommunity, isOwner: true)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
