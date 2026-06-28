import SwiftUI

struct ForgotPasswordFormSection: View {
    @Bindable var viewModel: ForgotPasswordViewModel

    var body: some View {
        AuthLabeledField(label: "Email") {
            AuthTextField(
                placeholder: "you@email.com",
                text: $viewModel.email,
                icon: "envelope",
                keyboardType: .emailAddress,
                contentType: .emailAddress,
                error: viewModel.emailError
            )
        }
    }
}

#Preview {
    ForgotPasswordFormSection(viewModel: ForgotPasswordViewModel())
        .padding()
        .background(Color.appBackground)
}
