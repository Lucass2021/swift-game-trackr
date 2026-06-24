import SwiftUI

struct RegisterFormSection: View {
    @Bindable var viewModel: RegisterViewModel

    var body: some View {
        VStack(spacing: 20) {
            AuthLabeledField(label: "Name") {
                AuthTextField(
                    placeholder: "Ex: John Doe",
                    text: $viewModel.name,
                    contentType: .name,
                    error: viewModel.nameError
                )
            }

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
                    contentType: .newPassword,
                    error: viewModel.passwordError
                )

                if !viewModel.password.isEmpty {
                    PasswordStrengthMeter(strength: PasswordStrength(password: viewModel.password))
                }
            }

            AuthLabeledField(label: "Confirm password") {
                AuthTextField(
                    placeholder: "••••••••",
                    text: $viewModel.confirmPassword,
                    isSecure: true,
                    contentType: .newPassword,
                    error: viewModel.confirmPasswordError
                )
            }
        }
    }
}

#Preview {
    RegisterFormSection(viewModel: RegisterViewModel())
        .padding()
        .background(Color.appBackground)
}
