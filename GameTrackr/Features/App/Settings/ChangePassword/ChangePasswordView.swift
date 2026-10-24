import SwiftUI

private enum Constants {
    static let placeholder = "••••••••"
}

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: ChangePasswordViewModel

    init(repository: PasswordRepository) {
        _viewModel = State(initialValue: ChangePasswordViewModel(repository: repository))
    }

    var body: some View {
        if viewModel.isChanged {
            SuccessView(
                title: "Password updated!",
                subtitle: "Your password was changed successfully.",
                buttonTitle: "Done",
                onPrimary: { dismiss() }
            )
        } else {
            formContent
        }
    }

    private var formContent: some View {
        VStack(spacing: 0) {
            StatsTopBar(title: "Change password", onBack: close)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    AuthLabeledField(label: "Current password") {
                        AuthTextField(
                            placeholder: Constants.placeholder,
                            text: binding(viewModel.currentPassword, viewModel.onCurrentPasswordChange),
                            isSecure: true,
                            contentType: .password,
                            error: viewModel.currentPasswordError
                        )
                    }

                    AuthLabeledField(label: "New password") {
                        AuthTextField(
                            placeholder: Constants.placeholder,
                            text: binding(viewModel.newPassword, viewModel.onNewPasswordChange),
                            isSecure: true,
                            contentType: .newPassword,
                            error: viewModel.newPasswordError
                        )

                        if !viewModel.newPassword.isEmpty {
                            PasswordStrengthMeter(strength: PasswordStrength(password: viewModel.newPassword))
                        }
                    }

                    AuthLabeledField(label: "Confirm new password") {
                        AuthTextField(
                            placeholder: Constants.placeholder,
                            text: binding(viewModel.confirmPassword, viewModel.onConfirmPasswordChange),
                            isSecure: true,
                            contentType: .newPassword,
                            error: viewModel.confirmPasswordError
                        )
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.xxxl)
            }

            PrimaryButton(title: "Save new password", isLoading: viewModel.isSaving) {
                Task { await viewModel.save() }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toast(message: $viewModel.toastMessage)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }

    private func close() {
        guard !viewModel.isSaving else { return }
        dismiss()
    }

    private func binding(_ value: String, _ onChange: @escaping (String) -> Void) -> Binding<String> {
        Binding(get: { value }, set: onChange)
    }
}

#Preview {
    NavigationStack {
        ChangePasswordView(repository: FakePasswordRepository())
    }
    .preferredColorScheme(.dark)
}
