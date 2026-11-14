import SwiftUI

nonisolated extension AchievementTier {
    var tint: Color {
        switch self {
        case .bronze: .appNeutral
        case .silver: .appTextSecondary
        case .gold: .appPrimary
        case .platinum: .appSecondary
        }
    }
}

extension AchievementTier {
    var icon: AppIcon {
        self == .platinum ? .trophy : .medal
    }
}
