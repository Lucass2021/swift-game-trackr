import SwiftUI

private enum Constants {
    static let iconBoxSize: CGFloat = 120
    static let iconSize: CGFloat = 56
    static let glowRadius: CGFloat = 30
    static let glowAlpha = 0.35
    static let titleSize: CGFloat = 24
    static let subtitleSize: CGFloat = 15
}

struct ProfileGuestState: View {
    let onCreateAccount: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            AppIconView(icon: .avatar, size: Constants.iconSize)
                .foregroundStyle(Color.appPrimary)
                .frame(width: Constants.iconBoxSize, height: Constants.iconBoxSize)
                .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
                .shadow(color: Color.appPrimary.opacity(Constants.glowAlpha), radius: Constants.glowRadius)
                .subtleBounce()

            Text("Guest")
                .font(.appHeadline(Constants.titleSize, weight: .heavy))
                .foregroundStyle(Color.appTextPrimary)
                .padding(.top, Spacing.xl)

            Text("You're browsing as a guest. Create an account to build a public profile with your stats.")
                .font(.appBody(Constants.subtitleSize))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, Spacing.xs)
                .padding(.horizontal, Spacing.xl)

            PrimaryButton(title: "Create an account", action: onCreateAccount)
                .padding(.top, Spacing.xl)
                .padding(.horizontal, Spacing.xxl)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ProfileGuestState(onCreateAccount: {})
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
