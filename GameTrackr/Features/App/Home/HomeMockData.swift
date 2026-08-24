import SwiftUI

struct AnticipatedGame: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let badge: String
    let badgeColor: Color
    let coverStart: Color
    let coverEnd: Color
}

enum HomeMockData {
    static let sampleGame = Game(
        id: 1,
        name: "Final Fantasy VII Rebirth",
        releaseDate: Date(timeIntervalSince1970: 1_709_251_200),
        platformNames: ["PS5"]
    )

    static let mostAnticipated: [AnticipatedGame] = [
        AnticipatedGame(
            title: "GTA VI",
            subtitle: "Coming to Next-Gen Consoles",
            badge: "2025",
            badgeColor: .appPrimary,
            coverStart: .coverVioletStart,
            coverEnd: .coverVioletEnd
        ),
        AnticipatedGame(
            title: "Hollow Knight: Silksong",
            subtitle: "PC, Switch, Xbox",
            badge: "TBA",
            badgeColor: .appSecondary,
            coverStart: .coverCyanStart,
            coverEnd: .coverCyanEnd
        ),
        AnticipatedGame(
            title: "Death Stranding 2",
            subtitle: "PS5",
            badge: "2025",
            badgeColor: .appPrimary,
            coverStart: .coverPineStart,
            coverEnd: .coverPineEnd
        )
    ]
}
