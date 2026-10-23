import SwiftUI

private enum Constants {
    static let avatarSize: CGFloat = 64
    static let nameSize: CGFloat = 18
    static let usernameSize: CGFloat = 14
    static let avatarGradientDepth = 0.28
}

struct EditProfilePreviewCard: View {
    let name: String
    let username: String
    let avatarHex: String

    var body: some View {
        HStack(spacing: Spacing.sm) {
            CommunityAvatar(
                start: Color(hex: avatarHex),
                end: Color(hex: avatarHex).darkened(by: Constants.avatarGradientDepth),
                size: Constants.avatarSize
            )

            VStack(alignment: .leading, spacing: Spacing.xxxs) {
                Text(name)
                    .font(.appHeadline(Constants.nameSize))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)

                Text(username)
                    .font(.appBody(Constants.usernameSize))
                    .foregroundStyle(Color.appPrimary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity)
        .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
        .animation(.easeOut(duration: Durations.short), value: avatarHex)
    }
}

#Preview {
    EditProfilePreviewCard(
        name: ProfileMockData.profile.name,
        username: ProfileMockData.profile.username,
        avatarHex: ProfileMockData.profile.avatarHex
    )
    .padding()
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
