import SwiftUI

private enum Constants {
    static let avatarSize: CGFloat = 44
    static let forwardIconSize: CGFloat = 16
    static let dividerThickness: CGFloat = 1
    static let nameSize: CGFloat = 15
    static let roleSize: CGFloat = 13
}

struct CommunityMembersSection: View {
    let members: [CommunityMember]
    var onSelect: (CommunityMember) -> Void = { _ in }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(members) { member in
                Button {
                    onSelect(member)
                } label: {
                    HStack(spacing: Spacing.sm) {
                        CommunityAvatar(start: member.avatarStart, end: member.avatarEnd, size: Constants.avatarSize)

                        VStack(alignment: .leading, spacing: Spacing.xxxs) {
                            Text(member.author)
                                .font(.appLabel(Constants.nameSize))
                                .foregroundStyle(Color.appPrimary)

                            Text(member.role)
                                .font(.appBody(Constants.roleSize))
                                .foregroundStyle(Color.appTextSecondary)
                        }

                        Spacer()

                        AppIconView(icon: .forward, size: Constants.forwardIconSize)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.sm)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("View \(member.author)'s profile")

                if member.id != members.last?.id {
                    Rectangle()
                        .fill(Color.appOutline)
                        .frame(height: Constants.dividerThickness)
                        .padding(.horizontal, Spacing.lg)
                }
            }
        }
        .padding(.top, Spacing.xxs)
    }
}

#Preview {
    CommunityMembersSection(members: CommunityMockData.members)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
