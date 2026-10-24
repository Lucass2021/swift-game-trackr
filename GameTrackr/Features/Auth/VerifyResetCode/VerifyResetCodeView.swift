import SwiftUI

struct VerifyResetCodeView: View {
    @State private var viewModel: VerifyResetCodeViewModel

    init(email: String) {
        _viewModel = State(initialValue: VerifyResetCodeViewModel(email: email))
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        return AuthScreenScaffold {
            BackButton()
                .staggeredAppear(0)

            TitleWithSubtitle(
                title: "Verify your email",
                subtitle: "We sent a code to \(viewModel.email)"
            )
            .padding(.top, Spacing.md)
            .staggeredAppear(1)

            OTPField(
                code: Binding(get: { viewModel.code }, set: viewModel.onCodeChange),
                length: VerifyResetCodeViewModel.codeLength
            )
            .padding(.top, Spacing.xxl)
            .staggeredAppear(2)

            if let codeError = viewModel.codeError {
                Text(codeError)
                    .font(.appBody(13))
                    .foregroundStyle(Color.appTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, Spacing.sm)
                    .padding(.leading, Spacing.xxs)
            }

            Spacer(minLength: 0)

            VerifyResetCodeBottomSection(
                seconds: viewModel.resendSeconds,
                onResend: { Task { await viewModel.resend() } },
                isLoading: viewModel.isLoading,
                onConfirm: { Task { await viewModel.submit() } }
            )
            .staggeredAppear(3)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $viewModel.verifiedCode) { code in
            ResetPasswordView(email: viewModel.email, code: code)
        }
        .toast(message: $viewModel.toastMessage)
    }
}

#Preview {
    NavigationStack {
        VerifyResetCodeView(email: "you@email.com")
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
