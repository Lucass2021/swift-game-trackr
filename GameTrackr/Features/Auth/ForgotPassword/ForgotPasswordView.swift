import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ForgotPasswordViewModel
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
        _viewModel = State(initialValue: ForgotPasswordViewModel(repository: repository))
    }

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
            VerifyResetCodeView(email: email, repository: repository)
        }
        .toast(message: $viewModel.toastMessage)
    }
}

#Preview {
    NavigationStack {
        ForgotPasswordView(repository: RemoteAuthRepository())
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
