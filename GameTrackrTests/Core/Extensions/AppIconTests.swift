import Testing
import UIKit
@testable import GameTrackr

@MainActor
struct AppIconTests {
    @Test func achievementTierIconsHaveAFilledVersion() {
        for name in ["trophy-fill", "medal-fill"] {
            #expect(UIImage(named: name) != nil, "Missing asset \(name)")
        }
    }
}
