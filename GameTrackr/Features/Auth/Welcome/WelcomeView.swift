import SwiftUI

struct WelcomeView: View {
    @State private var showRegister = false
    @State private var showLogin = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Image("logo-wordmark")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 28)
                        Spacer()
                    }
                    .staggeredAppear(0)

                    Spacer()

                    VStack(spacing: 20) {
                        Image("logo-hero")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 280)

                        Text("Your whole gaming journey in one place")
                            .font(.appBody(16))
                            .foregroundStyle(Color.appTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .staggeredAppear(1)

                    Spacer()

                    WelcomeBottomSection(showRegister: $showRegister, showLogin: $showLogin)
                        .staggeredAppear(2)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showRegister) {
                Text("Register")
            }
            .navigationDestination(isPresented: $showLogin) {
                Text("Sign in")
            }
        }
    }
}

#Preview {
    WelcomeView()
        .preferredColorScheme(.dark)
}
