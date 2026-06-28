import SwiftUI

struct ResetPasswordFormSection: View {
    @Bindable var viewModel: ResetPasswordViewModel

    var body: some View {
        VStack(spacing: 20) {
            AuthLabeledField(label: "New password") {
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

            AuthLabeledField(label: "Confirm new password") {
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
    ResetPasswordFormSection(viewModel: ResetPasswordViewModel(resetToken: "token"))
        .padding()
        .background(Color.appBackground)
}
