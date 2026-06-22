import SwiftUI

@main
struct GameTrackrApp: App {
    init() {
        AppFonts.register()
    }

    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .preferredColorScheme(.dark)
        }
    }
}
