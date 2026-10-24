import SwiftUI

struct RegisterBottomSection: View {
    let isLoading: Bool
    let onCreateAccount: () -> Void
    let onSignIn: () -> Void

    var body: some View {
        VStack(spacing: Spacing.lg) {
            PrimaryButton(title: "Create account", isLoading: isLoading, action: onCreateAccount)

            AuthPrompt(prefix: "Already have an account? ", actionText: "Sign in", action: onSignIn)
        }
    }
}

#Preview {
    RegisterBottomSection(isLoading: false, onCreateAccount: {}, onSignIn: {})
        .padding()
        .background(Color.appBackground)
}
