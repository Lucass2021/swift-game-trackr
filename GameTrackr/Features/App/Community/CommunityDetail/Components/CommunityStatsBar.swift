import SwiftUI

private enum Constants {
    static let borderWidth: CGFloat = 1
    static let dividerHeight: CGFloat = 34
    static let liveDotSize: CGFloat = 6
    static let valueSize: CGFloat = 19
    static let labelSize: CGFloat = 11
    static let labelTracking: CGFloat = 0.8
}

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
        .padding(.vertical, Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .stroke(Color.appOutline, lineWidth: Constants.borderWidth)
        )
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.appOutline)
            .frame(width: Constants.borderWidth, height: Constants.dividerHeight)
    }

    private func stat(value: String, label: String, isLive: Bool = false) -> some View {
        VStack(spacing: Spacing.xxs) {
            HStack(spacing: Spacing.xxs) {
                Text(value)
                    .font(.appHeadline(Constants.valueSize))
                    .foregroundStyle(Color.appTextPrimary)

                if isLive {
                    Circle()
                        .fill(Color.appPrimary)
                        .frame(width: Constants.liveDotSize, height: Constants.liveDotSize)
                }
            }

            Text(label.uppercased())
                .font(.appLabel(Constants.labelSize))
                .kerning(Constants.labelTracking)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    CommunityStatsBar(community: CommunityMockData.detailCommunity)
        .padding(Spacing.lg)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
