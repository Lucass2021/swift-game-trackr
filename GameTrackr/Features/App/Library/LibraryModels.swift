import SwiftUI

enum LibraryStatus: String, CaseIterable, Identifiable {
    case playing = "Playing"
    case completed = "Completed"
    case backlog = "Backlog"
    case platinum = "Platinum"
    case abandoned = "Abandoned"
    case wishlist = "Wishlist"

    var id: Self {
        self
    }

    var badgeBackground: Color {
        switch self {
        case .playing, .platinum: .appPrimary
        case .completed: .appSecondary
        case .backlog: .appOutline
        case .abandoned: .appTertiary.opacity(0.18)
        case .wishlist: .appSecondary.opacity(0.18)
        }
    }

    var badgeForeground: Color {
        switch self {
        case .playing, .completed, .platinum: .appOnPrimary
        case .backlog: .appTextSecondary
        case .abandoned: .appTertiary
        case .wishlist: .appSecondary
        }
    }
}

struct LibraryEntry: Identifiable {
    let id = UUID()
    let title: String
    let status: LibraryStatus
    let rating: Int
    let hours: Int
    let coverStart: Color
    let coverEnd: Color
}

struct LibraryStats {
    let totalGames: Int
    let platinum: Int
}
