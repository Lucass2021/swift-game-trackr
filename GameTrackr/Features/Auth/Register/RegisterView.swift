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
                subTitle: "Join the global community of players."
            )
            .padding(.top, 16)
            .staggeredAppear(1)

            RegisterFormSection(viewModel: viewModel)
                .padding(.top, 28)
                .staggeredAppear(2)

            TermsAcceptanceRow(isAccepted: $viewModel.acceptedTerms, error: viewModel.termsError)
                .padding(.top, 24)
                .staggeredAppear(3)

            RegisterBottomSection(
                isLoading: viewModel.isLoading,
                onCreateAccount: { Task { await viewModel.signUp(authStore: authStore) } },
                onSignIn: { showLogin = true }
            )
            .padding(.top, 24)
            .staggeredAppear(4)

            SocialLoginSection(action: { viewModel.signUpGoogle() })
                .padding(.top, 28)
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
        .toast(message: $viewModel.errorMessage)
        .onDisappear { viewModel.clear() }
    }
}

#Preview {
    NavigationStack {
        RegisterView()
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
