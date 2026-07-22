import SwiftUI

struct SuggestedCommunityCard: View {
    let community: Community
    var onSelect: () -> Void = {}
    var onJoin: () -> Void = {}

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onSelect) {
                HStack(spacing: 14) {
                    CommunityIcon(start: community.iconStart, end: community.iconEnd, size: 48)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(community.name)
                            .font(.appHeadline(17))
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(1)

                        Text("\(community.members) members")
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
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.appPrimary.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    SuggestedCommunityCard(community: CommunityMockData.suggested)
        .padding(20)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
