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
                subTitle: "We sent a code to \(viewModel.email)"
            )
            .padding(.top, 16)
            .staggeredAppear(1)

            OTPField(code: $viewModel.code)
                .padding(.top, 32)
                .staggeredAppear(2)
                .onChange(of: viewModel.code) { _, newValue in
                    guard newValue.count == 6 else { return }
                    Task { await viewModel.verify() }
                }

            if let codeError = viewModel.codeError {
                Text(codeError)
                    .font(.appBody(13))
                    .foregroundStyle(Color.appTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 12)
            }

            Spacer(minLength: 0)

            VerifyResetCodeBottomSection(viewModel: viewModel)
                .staggeredAppear(3)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $viewModel.showResetPassword) {
            ResetPasswordView(resetToken: viewModel.resetToken ?? "")
        }
        .toast(message: $viewModel.errorMessage)
        .task { await viewModel.startResendCountdown() }
    }
}

#Preview {
    NavigationStack {
        VerifyResetCodeView(email: "you@email.com")
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
