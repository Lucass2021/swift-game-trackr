import SwiftUI

struct CommunityRow: View {
    let community: Community
    var onSelect: () -> Void = {}
    var onJoin: () -> Void = {}

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onSelect) {
                HStack(spacing: 14) {
                    CommunityIcon(start: community.iconStart, end: community.iconEnd, size: 56)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(community.name)
                            .font(.appHeadline(17))
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(1)

                        Text(community.subtitle)
                            .font(.appBody(13))
                            .foregroundStyle(Color.appTextSecondary)

                        Text(community.description)
                            .font(.appBody(13))
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
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
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
