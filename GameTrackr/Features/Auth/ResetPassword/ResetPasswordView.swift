import SwiftUI

struct ResetPasswordView: View {
    @Environment(AuthStore.self) private var authStore
    @State private var viewModel: ResetPasswordViewModel

    init(resetToken: String) {
        _viewModel = State(initialValue: ResetPasswordViewModel(resetToken: resetToken))
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        return AuthScreenScaffold {
            BackButton()
                .staggeredAppear(0)

            Spacer(minLength: 0)

            TitleWithSubtitle(
                title: "Create new password",
                subTitle: "Your new password must be different from previously used passwords.",
                alignment: .center
            )
            .padding(.top, 16)
            .staggeredAppear(1)

            ResetPasswordFormSection(viewModel: viewModel)
                .padding(.top, 28)
                .staggeredAppear(2)

            ResetPasswordBottomSection(
                viewModel: viewModel,
                onSave: { Task { await viewModel.resetPassword() } }
            )
            .padding(.top, 28)
            .staggeredAppear(3)

            Spacer(minLength: 0)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $viewModel.showSuccess) {
            SuccessView(
                title: "All set!",
                subtitle: "Your password was changed successfully. You can now sign in with your new password.",
                statusTitle: "Account status",
                statusValue: "Validated and Active",
                buttonTitle: "Back to login",
                onPrimary: { authStore.isResetFlowActive = false }
            )
        }
        .toast(message: $viewModel.errorMessage)
    }
}

#Preview {
    NavigationStack {
        ResetPasswordView(resetToken: "token")
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
