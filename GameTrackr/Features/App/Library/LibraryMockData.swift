import SwiftUI

enum LibraryMockData {
    static let stats = LibraryStats(totalGames: 142, platinum: 21)

    static let entries: [LibraryEntry] = [
        LibraryEntry(
            title: "Cyberpunk 2077: Phantom Liberty",
            status: .playing,
            rating: 4,
            hours: 32,
            coverStart: .coverVioletStart,
            coverEnd: .coverVioletEnd
        ),
        LibraryEntry(
            title: "Starfield",
            status: .completed,
            rating: 5,
            hours: 128,
            coverStart: .coverIndigoStart,
            coverEnd: .coverIndigoEnd
        ),
        LibraryEntry(
            title: "Elden Ring",
            status: .backlog,
            rating: 0,
            hours: 0,
            coverStart: .coverCrimsonStart,
            coverEnd: .coverCrimsonEnd
        ),
        LibraryEntry(
            title: "Uncharted: Legacy of Thieves",
            status: .platinum,
            rating: 5,
            hours: 45,
            coverStart: .coverPineStart,
            coverEnd: .coverPineEnd
        ),
        LibraryEntry(
            title: "Forza Motorsport",
            status: .playing,
            rating: 4,
            hours: 12,
            coverStart: .coverAzureStart,
            coverEnd: .coverAzureEnd
        )
    ]
}
