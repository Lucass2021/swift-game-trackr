import SwiftUI

struct CommunityMembersSection: View {
    var onSelect: (CommunityMember) -> Void = { _ in }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(CommunityMockData.members) { member in
                Button {
                    onSelect(member)
                } label: {
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

                        AppIconView(icon: .forward, size: 16)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("View \(member.author)'s profile")

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
