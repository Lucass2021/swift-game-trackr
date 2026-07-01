import SwiftUI

struct WelcomeBackground: View {
    var body: some View {
        ZStack {
            Color.appBackground

            Image("welcome-bg")
                .resizable()
                .scaledToFill()
                .overlay {
                    LinearGradient(
                        stops: [
                            .init(color: .appBackground.opacity(0.55), location: 0.0),
                            .init(color: .appBackground.opacity(0.15), location: 0.35),
                            .init(color: .appBackground.opacity(0.85), location: 0.75),
                            .init(color: .appBackground, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        WelcomeBackground()
    }
}
