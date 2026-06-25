import SwiftUI

struct LoginView: View {
    @State private var viewModel = LoginViewModel()
    @State private var showRegister = false

    var body: some View {
        @Bindable var viewModel = viewModel

        return AuthScreenScaffold {
            BackButton()
                .staggeredAppear(0)

            Spacer(minLength: 0)

            TitleWithSubtitle(
                title: "Welcome back!",
                subTitle: "Access your account to continue tracking your gaming journey.",
                alignment: .center
            )
            .padding(.top, 16)
            .staggeredAppear(1)

            LoginFormSection(viewModel: viewModel)
                .padding(.top, 28)
                .staggeredAppear(2)

            RememberMeRow(
                rememberMe: $viewModel.rememberMe,
                onForgotPassword: { viewModel.forgotPassword() }
            )
            .padding(.top, 20)
            .staggeredAppear(3)

            PrimaryButton(title: "Sign in", isLoading: viewModel.isLoading) {
                Task { await viewModel.signIn() }
            }
            .padding(.top, 24)
            .staggeredAppear(4)

            SocialLoginSection(action: { viewModel.signInGoogle() })
                .padding(.top, 28)
                .staggeredAppear(5)

            signUpPrompt
                .padding(.top, 28)
                .staggeredAppear(6)

            Spacer(minLength: 0)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $showRegister) {
            RegisterView()
        }
        .onDisappear { viewModel.clear() }
    }

    private var signUpPrompt: some View {
        Text("Don't have an account? \(Text("Sign up").font(.appLabel(15)).foregroundStyle(Color.appSecondary))")
            .font(.appBody(15))
            .foregroundStyle(Color.appTextSecondary)
            .onTapGesture { showRegister = true }
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
    .preferredColorScheme(.dark)
}
