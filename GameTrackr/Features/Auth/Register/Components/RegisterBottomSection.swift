import SwiftUI

struct RegisterBottomSection: View {
    var isLoading: Bool
    var onCreateAccount: () -> Void
    var onSignIn: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            PrimaryButton(title: "Create account", isLoading: isLoading, action: onCreateAccount)

            Text("Already have an account? \(Text("Sign in").font(.appLabel(15)).foregroundStyle(Color.appSecondary))")
                .font(.appBody(15))
                .foregroundStyle(Color.appTextSecondary)
                .onTapGesture(perform: onSignIn)
        }
    }
}

#Preview {
    RegisterBottomSection(isLoading: false, onCreateAccount: {}, onSignIn: {})
        .padding()
        .background(Color.appBackground)
}
