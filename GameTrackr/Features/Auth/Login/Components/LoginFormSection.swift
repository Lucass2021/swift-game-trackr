import SwiftUI

struct LoginFormSection: View {
    let email: String
    let password: String
    let emailError: String?
    let passwordError: String?
    let onEmailChange: (String) -> Void
    let onPasswordChange: (String) -> Void

    var body: some View {
        VStack(spacing: Spacing.lg) {
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
                    contentType: .password,
                    error: passwordError
                )
            }
        }
    }
}

#Preview {
    LoginFormSection(
        email: "player@gametrackr.com",
        password: "",
        emailError: nil,
        passwordError: ValidationMessage.passwordRequired,
        onEmailChange: { _ in },
        onPasswordChange: { _ in }
    )
    .padding()
    .background(Color.appBackground)
}
