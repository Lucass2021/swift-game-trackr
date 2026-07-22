import SwiftUI

struct CommunityStatsBar: View {
    let community: Community

    var body: some View {
        HStack(spacing: 0) {
            stat(value: community.members, label: "Members")
            divider
            stat(value: community.posts, label: "Posts")
            divider
            stat(value: community.online, label: "Online", isLive: true)
        }
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.appOutline, lineWidth: 1)
        )
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.appOutline)
            .frame(width: 1, height: 34)
    }

    private func stat(value: String, label: String, isLive: Bool = false) -> some View {
        VStack(spacing: 5) {
            HStack(spacing: 6) {
                Text(value)
                    .font(.appHeadline(19))
                    .foregroundStyle(Color.appTextPrimary)

                if isLive {
                    Circle()
                        .fill(Color.appPrimary)
                        .frame(width: 6, height: 6)
                }
            }

            Text(label.uppercased())
                .font(.appLabel(11))
                .kerning(0.8)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    CommunityStatsBar(community: CommunityMockData.detailCommunity)
        .padding(20)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
