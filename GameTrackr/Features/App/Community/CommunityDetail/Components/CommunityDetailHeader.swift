import SwiftUI

struct CommunityDetailHeader: View {
    let community: Community

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            banner

            HStack(alignment: .center, spacing: 14) {
                CommunityIcon(start: community.iconStart, end: community.iconEnd, size: 80, cornerRadius: 18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.appBackground, lineWidth: 3)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(community.name)
                        .font(.appHeadline(24, weight: .heavy))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(community.detailSubtitle)
                        .font(.appBody(13))
                        .foregroundStyle(Color.appTextSecondary)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .offset(y: -40)
            .padding(.bottom, -28)
        }
    }

    private var banner: some View {
        LinearGradient(
            colors: [community.iconStart, community.iconEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(height: 180)
        .overlay {
            LinearGradient(
                colors: [.clear, Color.appBackground],
                startPoint: .center,
                endPoint: .bottom
            )
        }
        .overlay {
            AppIconView(icon: .community, size: 72)
                .foregroundStyle(Color.white.opacity(0.08))
        }
    }
}

#Preview {
    VStack {
        CommunityDetailHeader(community: CommunityMockData.detailCommunity)
        Spacer()
    }
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
