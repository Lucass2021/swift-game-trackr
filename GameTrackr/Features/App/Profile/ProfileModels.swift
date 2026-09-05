import SwiftUI

struct Profile {
    var name: String
    var username: String
    let bio: String
    let joinedAt: String
    var avatarHex: String
    let stats: ProfileStats
    var visibility: ProfileVisibility = .publicProfile

    var avatarStart: Color {
        Color(hex: avatarHex)
    }

    var avatarEnd: Color {
        Color(hex: avatarHex).darkened(by: 0.28)
    }

    func applying(_ user: User?) -> Profile {
        guard let user else { return self }
        var copy = self
        copy.name = user.name
        if let username = user.username { copy.username = "@\(username)" }
        if let color = user.profileColor { copy.avatarHex = color }
        return copy
    }
}

enum ProfileVisibility: String, CaseIterable, Identifiable {
    case publicProfile
    case privateProfile

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .publicProfile: "Public"
        case .privateProfile: "Private"
        }
    }

    var detail: String {
        switch self {
        case .publicProfile: "Anyone can find you and see your library and stats."
        case .privateProfile: "Only friends can see your library and stats."
        }
    }

    var icon: AppIcon {
        switch self {
        case .publicProfile: .eye
        case .privateProfile: .eyeSlash
        }
    }
}

enum ProfileHeaderMode: Equatable {
    case own
    case other(isFriend: Bool)
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
