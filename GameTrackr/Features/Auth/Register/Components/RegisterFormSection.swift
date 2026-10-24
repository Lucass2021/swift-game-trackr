import SwiftUI

struct RegisterFormSection: View {
    let name: String
    let email: String
    let password: String
    let confirmPassword: String
    let nameError: String?
    let emailError: String?
    let passwordError: String?
    let confirmPasswordError: String?
    let onNameChange: (String) -> Void
    let onEmailChange: (String) -> Void
    let onPasswordChange: (String) -> Void
    let onConfirmPasswordChange: (String) -> Void

    var body: some View {
        VStack(spacing: Spacing.lg) {
            AuthLabeledField(label: "Name") {
                AuthTextField(
                    placeholder: "Ex: John Doe",
                    text: Binding(get: { name }, set: onNameChange),
                    contentType: .name,
                    error: nameError
                )
            }

            AuthLabeledField(label: "Email") {
                AuthTextField(
                    placeholder: "you@email.com",
                    text: Binding(get: { email }, set: onEmailChange),
                    keyboardType: .emailAddress,
                    contentType: .emailAddress,
                    error: emailError
                )
            }

            AuthLabeledField(label: "Password") {
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

            AuthLabeledField(label: "Confirm password") {
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
    RegisterFormSection(
        name: "Player",
        email: "player@gametrackr.com",
        password: "secret123",
        confirmPassword: "secret",
        nameError: nil,
        emailError: nil,
        passwordError: nil,
        confirmPasswordError: ValidationMessage.passwordsDoNotMatch,
        onNameChange: { _ in },
        onEmailChange: { _ in },
        onPasswordChange: { _ in },
        onConfirmPasswordChange: { _ in }
    )
    .padding()
    .background(Color.appBackground)
}
