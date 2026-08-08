import SwiftUI

struct GameScreenshot: Identifiable {
    let id = UUID()
    let start: Color
    let end: Color
}

struct GameSpec: Identifiable {
    let id = UUID()
    let label: String
    let value: String
}

struct SystemRequirementTier: Identifiable {
    let id = UUID()
    let name: String
    let items: [GameSpec]
}

struct GameDetail {
    let title: String
    let year: String
    let rating: Double
    let platforms: [String]
    let genres: [String]
    let coverStart: Color
    let coverEnd: Color
    let screenshots: [GameScreenshot]
    let about: String
    let specs: [GameSpec]
    let systemRequirements: [SystemRequirementTier]

    var supportsPC: Bool {
        platforms.contains { $0.caseInsensitiveCompare("PC") == .orderedSame }
    }
}
