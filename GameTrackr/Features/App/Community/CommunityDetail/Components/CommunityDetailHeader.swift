import SwiftUI

private enum Constants {
    static let bannerHeight: CGFloat = 180
    static let bannerIconSize: CGFloat = 72
    static let bannerIconAlpha = 0.08
    static let iconSize: CGFloat = 80
    static let iconOverhang: CGFloat = 40
    static let iconBorderWidth: CGFloat = 3
    static let nameSize: CGFloat = 24
    static let subtitleSize: CGFloat = 13
}

struct CommunityDetailHeader: View {
    let community: Community

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            banner

            HStack(alignment: .center, spacing: Spacing.sm) {
                CommunityIcon(
                    start: community.iconStart,
                    end: community.iconEnd,
                    size: Constants.iconSize,
                    cornerRadius: Radius.lg
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                        .stroke(Color.appBackground, lineWidth: Constants.iconBorderWidth)
                )

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(community.name)
                        .font(.appHeadline(Constants.nameSize, weight: .heavy))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(community.detailSubtitle)
                        .font(.appBody(Constants.subtitleSize))
                        .foregroundStyle(Color.appTextSecondary)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, Spacing.lg)
            .offset(y: -Constants.iconOverhang)
            .padding(.bottom, Spacing.sm - Constants.iconOverhang)
        }
    }

    private var banner: some View {
        LinearGradient(
            colors: [community.iconStart, community.iconEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(height: Constants.bannerHeight)
        .overlay {
            LinearGradient(
                colors: [.clear, Color.appBackground],
                startPoint: .center,
                endPoint: .bottom
            )
        }
        .overlay {
            AppIconView(icon: .community, size: Constants.bannerIconSize)
                .foregroundStyle(Color.appTextPrimary.opacity(Constants.bannerIconAlpha))
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
