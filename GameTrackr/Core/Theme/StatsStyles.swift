import SwiftUI

private nonisolated enum Constants {
    static let primaryMutedAlpha = 0.5
    static let secondaryMutedAlpha = 0.45
}

nonisolated extension StatAccent {
    var color: Color {
        switch self {
        case .primary: .appPrimary
        case .secondary: .appSecondary
        case .primaryMuted: .appPrimary.opacity(Constants.primaryMutedAlpha)
        case .secondaryMuted: .appSecondary.opacity(Constants.secondaryMutedAlpha)
        }
    }
}

nonisolated extension StatBar {
    var tint: Color {
        accent.color
    }
}

nonisolated extension YearCount {
    var tint: Color {
        accent.color
    }
}
