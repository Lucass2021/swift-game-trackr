import SwiftUI

struct WelcomeView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var path: [AuthRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                HStack {
                    Image("logo-wordmark")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                    Spacer()
                }
                .staggeredAppear(0)

                Spacer()

                VStack(spacing: 20) {
                    Image("logo-hero")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 300)
                        .subtleBounce()

                    Text("Your whole gaming journey in one place")
                        .font(.appBody(18))
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .staggeredAppear(1)
                .padding(.bottom, 40)

                WelcomeBottomSection(
                    onCreateAccount: { open(.register) },
                    onSignIn: { open(.login) }
                )
                .staggeredAppear(2)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(WelcomeBackground())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .register:
                    RegisterView(
                        repository: dependencies.authRepository,
                        googleAuth: dependencies.googleAuth,
                        onSignIn: { open(.login) }
                    )
                case .login:
                    LoginView(
                        repository: dependencies.authRepository,
                        googleAuth: dependencies.googleAuth,
                        onSignUp: { open(.register) }
                    )
                }
            }
        }
    }

    private func open(_ route: AuthRoute) {
        path = openAuthRoute(route, in: path)
    }
}

#Preview {
    WelcomeView()
        .environment(AppDependencies())
        .preferredColorScheme(.dark)
}
