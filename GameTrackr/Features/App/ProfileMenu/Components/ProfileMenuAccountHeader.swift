import SwiftUI

struct ProfileMenuAccountHeader: View {
    let name: String
    let subtitle: String

    var body: some View {
        HStack(spacing: Spacing.sm) {
            AppIconView(icon: .avatar, filled: true, size: Constants.avatarSize)
                .foregroundStyle(Color.appTextSecondary)

            VStack(alignment: .leading, spacing: Spacing.xxxs) {
                if !name.isEmpty {
                    Text(name)
                        .font(.appHeadline(Constants.nameSize))
                        .foregroundStyle(Color.appTextPrimary)
                }

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.appBody(Constants.subtitleSize))
                        .foregroundStyle(Color.appTextSecondary)
                }
            }

            Spacer()
        }
        .padding(Spacing.md)
        .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: Radius.lg))
    }
}

private enum Constants {
    static let avatarSize: CGFloat = 44
    static let nameSize: CGFloat = 18
    static let subtitleSize: CGFloat = 14
}

#Preview {
    ProfileMenuAccountHeader(name: ProfileMockData.user.name, subtitle: ProfileMockData.user.email)
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
