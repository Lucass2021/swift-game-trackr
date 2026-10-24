import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ForgotPasswordViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        return AuthScreenScaffold {
            BackButton()
                .staggeredAppear(0)

            Spacer(minLength: 0)

            TitleWithSubtitle(
                title: "Reset password",
                subtitle: "Enter your email and we'll send you a code to create a new password."
            )
            .padding(.top, Spacing.md)
            .staggeredAppear(1)

            ForgotPasswordFormSection(
                email: viewModel.email,
                emailError: viewModel.emailError,
                onEmailChange: viewModel.onEmailChange
            )
            .padding(.top, Spacing.xl)
            .staggeredAppear(2)

            Spacer(minLength: 0)

            ForgotPasswordBottomSection(
                isLoading: viewModel.isLoading,
                onSendCode: { Task { await viewModel.submit() } },
                onBackToLogin: { dismiss() }
            )
            .staggeredAppear(3)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $viewModel.sentToEmail) { email in
            VerifyResetCodeView(email: email)
        }
        .toast(message: $viewModel.toastMessage)
    }
}

#Preview {
    NavigationStack {
        ForgotPasswordView()
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
