import SwiftUI

struct WelcomeBottomSection: View {
    let onCreateAccount: () -> Void
    let onSignIn: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            PrimaryButton(title: "Create account", action: onCreateAccount)

            SecondaryButton(title: "Sign in", action: onSignIn)

            Text(
                "By continuing, you agree to our **[Terms](https://github.com/lucianobcorrea/game-trackr-api)** and\n **[Privacy Policy](https://github.com/lucianobcorrea/game-trackr-api)**."
            )
            .font(.appBody(14))
            .tint(Color.appSecondary)
            .foregroundStyle(Color.appTextSecondary)
            .multilineTextAlignment(.center)
            .padding(.top, 6)
        }
    }
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        WelcomeBottomSection(onCreateAccount: {}, onSignIn: {})
            .padding(.horizontal, 24)
    }
}
