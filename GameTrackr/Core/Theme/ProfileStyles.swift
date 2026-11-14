import SwiftUI

private nonisolated enum Constants {
    static let avatarGradientDepth = 0.28
    static let wishlistTintAlpha = 0.55
}

nonisolated extension Profile {
    var avatarStart: Color {
        Color(hex: avatarHex)
    }

    var avatarEnd: Color {
        Color(hex: avatarHex).darkened(by: Constants.avatarGradientDepth)
    }
}

extension ProfileVisibility {
    var icon: AppIcon {
        switch self {
        case .publicProfile: .eye
        case .privateProfile: .eyeSlash
        }
    }
}

nonisolated extension ProfileColor {
    var color: Color {
        Color(hex: hex)
    }
}

nonisolated extension LibraryStatus {
    var barTint: Color {
        switch self {
        case .playing: .appPrimary
        case .completed: .appSecondary
        case .backlog: .appTextSecondary
        case .platinum: .appTextPrimary
        case .abandoned: .appTertiary
        case .wishlist: .appSecondary.opacity(Constants.wishlistTintAlpha)
        }
    }
}

extension ActivityKind {
    var icon: AppIcon {
        switch self {
        case .platinum: .medal
        case .completed: .success
        case .started: .brand
        case .rated: .like
        case .added: .addToLibrary
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
