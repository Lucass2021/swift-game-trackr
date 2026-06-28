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
                subTitle: "Enter your email and we'll send you a code to create a new password."
            )
            .padding(.top, 16)
            .staggeredAppear(1)

            ForgotPasswordFormSection(viewModel: viewModel)
                .padding(.top, 28)
                .staggeredAppear(2)

            Spacer(minLength: 0)

            ForgotPasswordBottomSection(viewModel: viewModel, onBackToLogin: { dismiss() })
                .staggeredAppear(3)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $viewModel.showVerifyCode) {
            VerifyResetCodeView(email: viewModel.email)
        }
        .toast(message: $viewModel.errorMessage)
    }
}

#Preview {
    NavigationStack {
        ForgotPasswordView()
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
