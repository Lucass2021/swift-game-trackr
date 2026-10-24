import SwiftUI

struct LoginView: View {
    @Environment(AuthStore.self) private var authStore
    @State private var viewModel = LoginViewModel()
    @State private var showRegister = false

    var body: some View {
        @Bindable var viewModel = viewModel
        @Bindable var authStore = authStore

        return AuthScreenScaffold {
            BackButton()
                .staggeredAppear(0)

            Spacer(minLength: 0)

            TitleWithSubtitle(
                title: "Welcome back!",
                subtitle: "Access your account to continue tracking your gaming journey.",
                alignment: .center
            )
            .padding(.top, Spacing.md)
            .staggeredAppear(1)

            LoginFormSection(
                email: viewModel.email,
                password: viewModel.password,
                emailError: viewModel.emailError,
                passwordError: viewModel.passwordError,
                onEmailChange: viewModel.onEmailChange,
                onPasswordChange: viewModel.onPasswordChange
            )
            .padding(.top, Spacing.xl)
            .staggeredAppear(2)

            ForgotPasswordRow(
                onForgotPassword: { authStore.isResetFlowActive = true }
            )
            .padding(.top, Spacing.lg)
            .staggeredAppear(3)

            PrimaryButton(title: "Sign in", isLoading: viewModel.isLoading) {
                Task { await viewModel.submit(authStore: authStore) }
            }
            .padding(.top, Spacing.xl)
            .staggeredAppear(4)

            SocialLoginSection(action: {
                Task { await viewModel.signInWithGoogle(authStore: authStore) }
            })
            .padding(.top, Spacing.xl)
            .staggeredAppear(5)

            AuthPrompt(prefix: "Don't have an account? ", actionText: "Sign up") {
                showRegister = true
            }
            .padding(.top, Spacing.xl)
            .staggeredAppear(6)

            AuthPrompt(prefix: "Just exploring? ", actionText: "Continue as guest") {
                authStore.continueAsGuest()
            }
            .padding(.top, Spacing.md)
            .staggeredAppear(7)

            Spacer(minLength: 0)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $showRegister) {
            RegisterView()
        }
        .navigationDestination(isPresented: $authStore.isResetFlowActive) {
            ForgotPasswordView()
        }
        .toast(message: $viewModel.toastMessage)
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
