import SwiftUI

enum GamePlatform: String, CaseIterable, Identifiable {
    case pc = "PC"
    case playstation = "PlayStation"
    case xbox = "Xbox"
    case nintendo = "Nintendo"

    var id: Self {
        self
    }
}

struct SearchGame: Identifiable {
    let id = UUID()
    let title: String
    let year: String
    let platformsLabel: String
    let platforms: Set<GamePlatform>
    let coverStart: Color
    let coverEnd: Color
}

enum SearchMockData {
    static let games: [SearchGame] = [
        SearchGame(
            title: "Cyber-Drift 2099",
            year: "2023",
            platformsLabel: "PS5, PC",
            platforms: [.playstation, .pc],
            coverStart: .coverVioletStart,
            coverEnd: .coverVioletEnd
        ),
        SearchGame(
            title: "Aether Reach",
            year: "2024",
            platformsLabel: "PC, Xbox",
            platforms: [.pc, .xbox],
            coverStart: .coverCyanStart,
            coverEnd: .coverCyanEnd
        ),
        SearchGame(
            title: "Soul Ember",
            year: "2023",
            platformsLabel: "PS5",
            platforms: [.playstation],
            coverStart: .coverCrimsonStart,
            coverEnd: .coverCrimsonEnd
        ),
        SearchGame(
            title: "Tactical Grid",
            year: "2024",
            platformsLabel: "PC",
            platforms: [.pc],
            coverStart: .coverPineStart,
            coverEnd: .coverPineEnd
        ),
        SearchGame(
            title: "V-Velocity",
            year: "2023",
            platformsLabel: "PS5, Switch",
            platforms: [.playstation, .nintendo],
            coverStart: .coverEmeraldStart,
            coverEnd: .coverEmeraldEnd
        ),
        SearchGame(
            title: "Frost Bound",
            year: "2024",
            platformsLabel: "PC, Xbox",
            platforms: [.pc, .xbox],
            coverStart: .coverAzureStart,
            coverEnd: .coverAzureEnd
        ),
        SearchGame(
            title: "Astral Vanguard",
            year: "2024",
            platformsLabel: "PS5, PC, Xbox",
            platforms: [.playstation, .pc, .xbox],
            coverStart: .coverIndigoStart,
            coverEnd: .coverIndigoEnd
        ),
        SearchGame(
            title: "Iron Requiem",
            year: "2022",
            platformsLabel: "PC, Switch",
            platforms: [.pc, .nintendo],
            coverStart: .coverPineStart,
            coverEnd: .coverPineEnd
        )
    ]
}
