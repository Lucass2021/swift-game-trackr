import SwiftUI

struct ForgotPasswordBottomSection: View {
    let isLoading: Bool
    let onSendCode: () -> Void
    let onBackToLogin: () -> Void

    var body: some View {
        VStack(spacing: Spacing.lg) {
            PrimaryButton(title: "Send code", isLoading: isLoading, action: onSendCode)

            Button(action: onBackToLogin) {
                Text("Back to login")
                    .font(.appLabel(15))
                    .foregroundStyle(Color.appSecondary)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ForgotPasswordBottomSection(isLoading: false, onSendCode: {}, onBackToLogin: {})
        .padding()
        .background(Color.appBackground)
}
