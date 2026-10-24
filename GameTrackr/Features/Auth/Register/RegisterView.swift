import SwiftUI

struct RegisterView: View {
    @Environment(AuthStore.self) private var authStore
    @State private var viewModel = RegisterViewModel()
    @State private var showLogin = false

    var body: some View {
        @Bindable var viewModel = viewModel

        return AuthScreenScaffold {
            BackButton()
                .staggeredAppear(0)

            TitleWithSubtitle(
                title: "Create your profile",
                subtitle: "Join the global community of players."
            )
            .padding(.top, Spacing.md)
            .staggeredAppear(1)

            RegisterFormSection(
                name: viewModel.name,
                email: viewModel.email,
                password: viewModel.password,
                confirmPassword: viewModel.confirmPassword,
                nameError: viewModel.nameError,
                emailError: viewModel.emailError,
                passwordError: viewModel.passwordError,
                confirmPasswordError: viewModel.confirmPasswordError,
                onNameChange: viewModel.onNameChange,
                onEmailChange: viewModel.onEmailChange,
                onPasswordChange: viewModel.onPasswordChange,
                onConfirmPasswordChange: viewModel.onConfirmPasswordChange
            )
            .padding(.top, Spacing.xl)
            .staggeredAppear(2)

            TermsAcceptanceRow(
                isAccepted: viewModel.acceptedTerms,
                error: viewModel.termsError,
                onToggle: viewModel.onToggleTerms
            )
            .padding(.top, Spacing.xl)
            .staggeredAppear(3)

            RegisterBottomSection(
                isLoading: viewModel.isLoading,
                onCreateAccount: { Task { await viewModel.submit() } },
                onSignIn: { showLogin = true }
            )
            .padding(.top, Spacing.xl)
            .staggeredAppear(4)

            SocialLoginSection(action: {
                Task { await viewModel.signUpWithGoogle(authStore: authStore) }
            })
            .padding(.top, Spacing.xl)
            .staggeredAppear(5)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $showLogin) {
            LoginView()
        }
        .navigationDestination(isPresented: $viewModel.showSuccess) {
            SuccessView(
                title: "Account created!",
                subtitle: "Your account is ready. Jump in and start tracking your gaming journey.",
                statusTitle: "Account status",
                statusValue: "Validated and Active",
                buttonTitle: "Go to app",
                onPrimary: { viewModel.completeRegistration(authStore: authStore) }
            )
        }
        .toast(message: $viewModel.toastMessage)
    }
}

#Preview {
    NavigationStack {
        RegisterView()
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
