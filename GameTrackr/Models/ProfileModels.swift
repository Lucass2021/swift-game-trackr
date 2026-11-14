import SwiftUI

nonisolated struct Profile {
    var name: String
    var username: String
    var bio: String
    var joinedAt: Date?
    var avatarHex: String
    var visibility: ProfileVisibility = .publicProfile

    var avatarStart: Color {
        Color(hex: avatarHex)
    }

    var avatarEnd: Color {
        Color(hex: avatarHex).darkened(by: 0.28)
    }
}

nonisolated extension Profile {
    static let defaultAvatarHex = "#8B5CF6"

    init(user: User) {
        self.init(
            name: user.name,
            username: user.username.map { "@\($0)" } ?? "",
            bio: user.bio ?? "",
            joinedAt: user.createdAt,
            avatarHex: user.profileColor ?? Self.defaultAvatarHex,
            visibility: user.visibility
        )
    }
}

nonisolated enum ProfileVisibility: String, CaseIterable, Identifiable {
    case publicProfile = "public"
    case privateProfile = "private"

    init(apiValue: String?) {
        self = apiValue.flatMap(Self.init(rawValue:)) ?? .publicProfile
    }

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

nonisolated struct ProfileStats {
    let totalGames: Int
    let hours: Int
    let platinum: Int

    var platinumRate: Int {
        guard totalGames > 0 else { return 0 }
        return Int((Double(platinum) / Double(totalGames) * 100).rounded())
    }
}

nonisolated struct StatusCount: Identifiable {
    var id: LibraryStatus {
        status
    }

    let status: LibraryStatus
    let count: Int
}

nonisolated enum ActivityKind {
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

nonisolated struct ActivityEvent: Identifiable {
    let id: Int
    let kind: ActivityKind
    let gameTitle: String
    let detail: String?
    let timeAgo: String

    init(id: Int, kind: ActivityKind, gameTitle: String, detail: String? = nil, timeAgo: String) {
        self.id = id
        self.kind = kind
        self.gameTitle = gameTitle
        self.detail = detail
        self.timeAgo = timeAgo
    }
}

nonisolated struct ProfileOverview {
    let stats: ProfileStats
    let breakdown: [StatusCount]
    let favorites: [LibraryEntry]
    let currentlyPlaying: [LibraryEntry]
    let activity: [ActivityEvent]
}

nonisolated struct UserOverview {
    let name: String
    let username: String
    let avatarHex: String
    let bio: String
    let joinedAt: Date?
    let isFriend: Bool
    let overview: ProfileOverview
}
