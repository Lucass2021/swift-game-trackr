import SwiftUI

struct ForgotPasswordFormSection: View {
    let email: String
    let emailError: String?
    let onEmailChange: (String) -> Void

    var body: some View {
        AuthLabeledField(label: "Email") {
            AuthTextField(
                placeholder: "you@email.com",
                text: Binding(get: { email }, set: onEmailChange),
                icon: .envelope,
                keyboardType: .emailAddress,
                contentType: .emailAddress,
                error: emailError
            )
        }
    }
}

#Preview {
    ForgotPasswordFormSection(email: "player", emailError: ValidationMessage.emailInvalid) { _ in }
        .padding()
        .background(Color.appBackground)
}
