import SwiftUI

struct CommunityAboutSection: View {
    let community: Community

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(community.description)
                .font(.appBody(15))
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 0) {
                infoRow(icon: .community, label: "Category", value: "#\(community.category)")
                Rectangle().fill(Color.appOutline).frame(height: 1)
                infoRow(icon: .calendar, label: "Created", value: "March 2024")
                Rectangle().fill(Color.appOutline).frame(height: 1)
                infoRow(icon: .medal, label: "Moderators", value: "3")
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.appSurfaceCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.appOutline, lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }

    private func infoRow(icon: AppIcon, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            AppIconView(icon: icon, size: 18)
                .foregroundStyle(Color.appTextSecondary)

            Text(label)
                .font(.appBody(15))
                .foregroundStyle(Color.appTextSecondary)

            Spacer()

            Text(value)
                .font(.appLabel(15))
                .foregroundStyle(Color.appTextPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
    }
}

#Preview {
    CommunityAboutSection(community: CommunityMockData.detailCommunity)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
