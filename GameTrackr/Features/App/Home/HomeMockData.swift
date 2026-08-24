import SwiftUI

enum HomeMockData {
    static let sampleGame = Game(
        id: 1,
        name: "Final Fantasy VII Rebirth",
        releaseDate: Date(timeIntervalSince1970: 1_709_251_200),
        platformNames: ["PS5"]
    )
}
