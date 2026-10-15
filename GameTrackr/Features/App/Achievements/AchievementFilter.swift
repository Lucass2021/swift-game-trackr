import SwiftUI

enum AchievementFilter: CaseIterable, Identifiable {
    case all
    case inProgress
    case completed

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .all: "All"
        case .inProgress: "In progress"
        case .completed: "Completed"
        }
    }

    func matches(_ game: GameAchievements) -> Bool {
        switch self {
        case .all: true
        case .inProgress: !game.isComplete && game.unlockedCount > 0
        case .completed: game.isComplete
        }
    }
}
