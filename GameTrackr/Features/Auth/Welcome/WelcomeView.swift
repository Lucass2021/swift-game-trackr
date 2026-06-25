import SwiftUI

struct WelcomeView: View {
    @State private var showRegister = false
    @State private var showLogin = false

    var body: some View {
        NavigationStack {
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

                    Text("Your whole gaming journey in one place")
                        .font(.appBody(18))
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .staggeredAppear(1)
                .padding(.bottom, 40)

                WelcomeBottomSection(showRegister: $showRegister, showLogin: $showLogin)
                    .staggeredAppear(2)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(WelcomeBackground())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
            .navigationDestination(isPresented: $showLogin) {
                LoginView()
            }
        }
    }
}

#Preview {
    WelcomeView()
        .preferredColorScheme(.dark)
}
