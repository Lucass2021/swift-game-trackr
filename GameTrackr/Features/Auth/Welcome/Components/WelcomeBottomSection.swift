import SwiftUI

struct WelcomeBottomSection: View {
    @Binding var showRegister: Bool
    @Binding var showLogin: Bool

    var body: some View {
        VStack(spacing: 14) {
            PrimaryButton(title: "Create account") {
                showRegister = true
            }

            SecondaryButton(title: "Sign in") {
                showLogin = true
            }

            Text("By continuing, you agree to our **[Terms](https://github.com/lucianobcorrea/game-trackr-api)** and **[Privacy Policy](https://github.com/lucianobcorrea/game-trackr-api)**.")
                .font(.appBody(13))
                .tint(Color.appSecondary)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 6)
        }
    }
}

#Preview {
    @Previewable @State var showRegister = false
    @Previewable @State var showLogin = false
    ZStack {
        Color.appBackground.ignoresSafeArea()
        WelcomeBottomSection(showRegister: $showRegister, showLogin: $showLogin)
            .padding(.horizontal, 24)
    }
}
