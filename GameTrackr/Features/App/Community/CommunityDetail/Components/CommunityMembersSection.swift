import SwiftUI

struct CommunityMembersSection: View {
    var body: some View {
        VStack(spacing: 0) {
            ForEach(CommunityMockData.members) { member in
                HStack(spacing: 14) {
                    CommunityAvatar(start: member.avatarStart, end: member.avatarEnd, size: 44)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(member.author)
                            .font(.appLabel(15))
                            .foregroundStyle(Color.appPrimary)

                        Text(member.role)
                            .font(.appBody(13))
                            .foregroundStyle(Color.appTextSecondary)
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                if member.id != CommunityMockData.members.last?.id {
                    Rectangle()
                        .fill(Color.appOutline)
                        .frame(height: 1)
                        .padding(.horizontal, 20)
                }
            }
        }
        .padding(.top, 4)
    }
}

#Preview {
    CommunityMembersSection()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
