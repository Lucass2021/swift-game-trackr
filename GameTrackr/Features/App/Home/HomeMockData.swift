import SwiftUI

struct NewRelease: Identifiable {
    let id = UUID()
    let title: String
    let platforms: String
    let coverStart: Color
    let coverEnd: Color
}

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
    static let newReleases: [NewRelease] = [
        NewRelease(
            title: "Final Fantasy VII Rebirth",
            platforms: "PS5",
            coverStart: .coverEmeraldStart,
            coverEnd: .coverEmeraldEnd
        ),
        NewRelease(
            title: "Dragon's Dogma 2",
            platforms: "PC, PS5, Xbox",
            coverStart: .coverCrimsonStart,
            coverEnd: .coverCrimsonEnd
        ),
        NewRelease(
            title: "Rise of the Ronin",
            platforms: "PS5",
            coverStart: .coverIndigoStart,
            coverEnd: .coverIndigoEnd
        ),
        NewRelease(
            title: "Helldivers 2",
            platforms: "PC, PS5",
            coverStart: .coverAzureStart,
            coverEnd: .coverAzureEnd
        )
    ]

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
