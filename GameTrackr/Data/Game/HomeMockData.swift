import SwiftUI

enum HomeMockData {
    static let sampleGame = Game(
        id: 1,
        name: "Final Fantasy VII Rebirth",
        releaseDate: Date(timeIntervalSince1970: 1_709_251_200),
        platformNames: ["PS5"]
    )

    static let platforms = [
        GamePlatform(id: 6, slug: "win", name: "PC (Microsoft Windows)"),
        GamePlatform(id: 167, slug: "ps5", name: "PlayStation 5"),
        GamePlatform(id: 169, slug: "series-x-s", name: "Xbox Series X|S")
    ]
}
