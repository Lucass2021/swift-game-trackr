import SwiftUI

struct ResetPasswordView: View {
    @Environment(AuthStore.self) private var authStore
    @State private var viewModel: ResetPasswordViewModel

    init(email: String, code: String) {
        _viewModel = State(initialValue: ResetPasswordViewModel(email: email, code: code))
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        return AuthScreenScaffold {
            BackButton()
                .staggeredAppear(0)

            Spacer(minLength: 0)

            TitleWithSubtitle(
                title: "Create new password",
                subtitle: "Your new password must be different from previously used passwords.",
                alignment: .center
            )
            .padding(.top, Spacing.md)
            .staggeredAppear(1)

            ResetPasswordFormSection(
                password: viewModel.password,
                confirmPassword: viewModel.confirmPassword,
                passwordError: viewModel.passwordError,
                confirmPasswordError: viewModel.confirmPasswordError,
                onPasswordChange: viewModel.onPasswordChange,
                onConfirmPasswordChange: viewModel.onConfirmPasswordChange
            )
            .padding(.top, Spacing.xl)
            .staggeredAppear(2)

            ResetPasswordBottomSection(
                isLoading: viewModel.isLoading,
                onSave: { Task { await viewModel.submit() } }
            )
            .padding(.top, Spacing.xl)
            .staggeredAppear(3)

            Spacer(minLength: 0)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $viewModel.showSuccess) {
            SuccessView(
                title: "All set!",
                subtitle: "Your password was changed successfully. Continue to sign in to your account.",
                statusTitle: "Account status",
                statusValue: "Validated and Active",
                buttonTitle: "Continue",
                onPrimary: { Task { await viewModel.signInAfterReset(authStore: authStore) } }
            )
        }
        .toast(message: $viewModel.toastMessage)
    }
}

#Preview {
    NavigationStack {
        ResetPasswordView(email: "you@email.com", code: "123456")
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
