import SwiftUI

struct FeaturedCommunityCard: View {
    let community: Community
    var onSelect: () -> Void = {}
    var onJoin: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onSelect) {
                VStack(alignment: .leading, spacing: 0) {
                    banner

                    VStack(alignment: .leading, spacing: 3) {
                        Text(community.name)
                            .font(.appHeadline(17))
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(1)

                        Text("\(community.members) members")
                            .font(.appBody(13))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 26)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())

            HStack {
                Spacer()
                JoinButton(isJoined: community.isJoined, action: onJoin)
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 14)
        }
        .frame(width: 210)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.appOutline, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var banner: some View {
        LinearGradient(
            colors: [community.iconStart, community.iconEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(height: 90)
        .overlay(alignment: .bottomLeading) {
            CommunityIcon(start: community.iconStart, end: community.iconEnd, size: 48, cornerRadius: 12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.appSurfaceCard, lineWidth: 3)
                )
                .padding(.leading, 14)
                .offset(y: 22)
        }
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack(spacing: 14) {
            ForEach(CommunityMockData.featured) { community in
                FeaturedCommunityCard(community: community)
            }
        }
        .padding(20)
    }
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
