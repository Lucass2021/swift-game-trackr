import SwiftUI

struct HomePlaceholderView: View {
    @Environment(AuthStore.self) private var authStore

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image("logo-hero")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 220)

            Text("Welcome\(authStore.currentUser.map { ", \($0.name)" } ?? "")!")
                .font(.appHeadline(22))
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)

            Text("You're signed in. The library is coming next.")
                .font(.appBody(15))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)

            Spacer()

            SecondaryButton(title: "Sign out") {
                authStore.logout()
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}

#Preview {
    HomePlaceholderView()
        .environment(AuthStore())
        .preferredColorScheme(.dark)
}
