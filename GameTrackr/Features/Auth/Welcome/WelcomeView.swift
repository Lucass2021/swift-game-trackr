import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Welcome to GameTrackr!")
        }
        .padding()
    }
}

#Preview {
    WelcomeView()
}
