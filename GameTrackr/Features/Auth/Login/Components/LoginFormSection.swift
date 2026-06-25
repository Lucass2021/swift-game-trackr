import SwiftUI

struct LoginFormSection: View {
    @Bindable var viewModel: LoginViewModel

    var body: some View {
        VStack(spacing: 20) {
            AuthLabeledField(label: "Email") {
                AuthTextField(
                    placeholder: "you@email.com",
                    text: $viewModel.email,
                    keyboardType: .emailAddress,
                    contentType: .emailAddress,
                    error: viewModel.emailError
                )
            }

            AuthLabeledField(label: "Password") {
                AuthTextField(
                    placeholder: "••••••••",
                    text: $viewModel.password,
                    isSecure: true,
                    contentType: .password,
                    error: viewModel.passwordError
                )
            }
        }
    }
}

#Preview {
    LoginFormSection(viewModel: LoginViewModel())
        .padding()
        .background(Color.appBackground)
}
