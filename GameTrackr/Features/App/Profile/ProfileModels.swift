import SwiftUI

struct Profile {
    let name: String
    let username: String
    let bio: String
    let joinedAt: String
    let avatarStart: Color
    let avatarEnd: Color
    let stats: ProfileStats
}

struct ProfileStats {
    let totalGames: Int
    let hours: Int
    let platinum: Int

    var platinumRate: Int {
        guard totalGames > 0 else { return 0 }
        return Int((Double(platinum) / Double(totalGames) * 100).rounded())
    }
}

struct StatusCount: Identifiable {
    var id: LibraryStatus {
        status
    }

    let status: LibraryStatus
    let count: Int
}

enum ActivityKind {
    case platinum
    case completed
    case started
    case rated
    case added

    var icon: AppIcon {
        switch self {
        case .platinum: .medal
        case .completed: .success
        case .started: .brand
        case .rated: .like
        case .added: .addToLibrary
        }
    }

    var verb: String {
        switch self {
        case .platinum: "Platinum on"
        case .completed: "Completed"
        case .started: "Started playing"
        case .rated: "Rated"
        case .added: "Added to library"
        }
    }

    var tint: Color {
        switch self {
        case .platinum, .started: .appPrimary
        case .completed: .appSecondary
        case .rated: .appTertiary
        case .added: .appTextSecondary
        }
    }
}

struct ActivityEvent: Identifiable {
    let id = UUID()
    let kind: ActivityKind
    let gameTitle: String
    let detail: String?
    let timeAgo: String

    init(kind: ActivityKind, gameTitle: String, detail: String? = nil, timeAgo: String) {
        self.kind = kind
        self.gameTitle = gameTitle
        self.detail = detail
        self.timeAgo = timeAgo
    }
}
