import SwiftUI

private enum Constants {
    static let iconSize: CGFloat = 56
    static let nameSize: CGFloat = 17
    static let detailSize: CGFloat = 13
}

struct CommunityRow: View {
    let community: Community
    var isOwner = false
    var onSelect: () -> Void = {}
    var onJoin: () -> Void = {}

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Button(action: onSelect) {
                HStack(spacing: Spacing.sm) {
                    CommunityIcon(start: community.iconStart, end: community.iconEnd, size: Constants.iconSize)

                    VStack(alignment: .leading, spacing: Spacing.xxxs) {
                        Text(community.name)
                            .font(.appHeadline(Constants.nameSize))
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(1)

                        Text(community.subtitle)
                            .font(.appBody(Constants.detailSize))
                            .foregroundStyle(Color.appTextSecondary)

                        Text(community.description)
                            .font(.appBody(Constants.detailSize))
                            .foregroundStyle(Color.appTextSecondary)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())

            JoinButton(isJoined: community.isJoined, isEnabled: !isOwner, action: onJoin)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
    }
}

#Preview {
    VStack(spacing: 0) {
        ForEach(CommunityMockData.all) { community in
            CommunityRow(community: community)
        }
    }
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
