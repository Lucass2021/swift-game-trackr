import SwiftUI

private enum Constants {
    static let iconSize: CGFloat = 48
    static let nameSize: CGFloat = 17
    static let detailSize: CGFloat = 13
    static let borderOpacity = 0.3
    static let borderWidth: CGFloat = 1
}

struct SuggestedCommunityCard: View {
    let community: Community
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

                        Text("\(community.members) members")
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

            JoinButton(isJoined: community.isJoined, action: onJoin)
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .stroke(Color.appPrimary.opacity(Constants.borderOpacity), lineWidth: Constants.borderWidth)
        )
    }
}

#Preview {
    SuggestedCommunityCard(community: CommunityMockData.suggested)
        .padding(Spacing.lg)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
