import SwiftUI

struct LoginView: View {
    @Environment(AuthStore.self) private var authStore
    @State private var viewModel: LoginViewModel
    private let repository: AuthRepository
    let onSignUp: () -> Void

    init(repository: AuthRepository, googleAuth: GoogleAuth, onSignUp: @escaping () -> Void) {
        self.repository = repository
        _viewModel = State(initialValue: LoginViewModel(repository: repository, googleAuth: googleAuth))
        self.onSignUp = onSignUp
    }

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

            AuthPrompt(prefix: "Don't have an account? ", actionText: "Sign up", action: onSignUp)
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
        .navigationDestination(isPresented: $authStore.isResetFlowActive) {
            ForgotPasswordView(repository: repository)
        }
        .toast(message: $viewModel.toastMessage)
    }
}

#Preview {
    let dependencies = AppDependencies()
    NavigationStack {
        LoginView(repository: dependencies.authRepository, googleAuth: dependencies.googleAuth, onSignUp: {})
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
