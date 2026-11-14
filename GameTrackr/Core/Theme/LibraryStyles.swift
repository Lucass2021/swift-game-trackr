import SwiftUI

private nonisolated enum Constants {
    static let softBadgeAlpha = 0.18
    static let wishlistTintAlpha = 0.55
}

nonisolated extension LibraryStatus {
    var badgeBackground: Color {
        switch self {
        case .playing, .platinum: .appPrimary
        case .completed: .appSecondary
        case .backlog: .appOutline
        case .abandoned: .appTertiary.opacity(Constants.softBadgeAlpha)
        case .wishlist: .appSecondary.opacity(Constants.softBadgeAlpha)
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
