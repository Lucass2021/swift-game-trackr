import SwiftUI

struct ResetPasswordFormSection: View {
    let password: String
    let confirmPassword: String
    let passwordError: String?
    let confirmPasswordError: String?
    let onPasswordChange: (String) -> Void
    let onConfirmPasswordChange: (String) -> Void

    var body: some View {
        VStack(spacing: Spacing.lg) {
            AuthLabeledField(label: "New password") {
                AuthTextField(
                    placeholder: "••••••••",
                    text: Binding(get: { password }, set: onPasswordChange),
                    isSecure: true,
                    contentType: .newPassword,
                    error: passwordError
                )

                if !password.isEmpty {
                    PasswordStrengthMeter(strength: PasswordStrength(password: password))
                }
            }

            AuthLabeledField(label: "Confirm new password") {
                AuthTextField(
                    placeholder: "••••••••",
                    text: Binding(get: { confirmPassword }, set: onConfirmPasswordChange),
                    isSecure: true,
                    contentType: .newPassword,
                    error: confirmPasswordError
                )
            }
        }
    }
}

#Preview {
    ResetPasswordFormSection(
        password: "secret123",
        confirmPassword: "secret",
        passwordError: nil,
        confirmPasswordError: ValidationMessage.passwordsDoNotMatch,
        onPasswordChange: { _ in },
        onConfirmPasswordChange: { _ in }
    )
    .padding()
    .background(Color.appBackground)
}
