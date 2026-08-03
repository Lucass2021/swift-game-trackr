import SwiftUI

enum AchievementTier: CaseIterable {
    case bronze
    case silver
    case gold
    case platinum

    var title: String {
        switch self {
        case .bronze: "Bronze"
        case .silver: "Silver"
        case .gold: "Gold"
        case .platinum: "Platinum"
        }
    }

    var tint: Color {
        switch self {
        case .bronze: .appNeutral
        case .silver: .appTextSecondary
        case .gold: .appPrimary
        case .platinum: .appSecondary
        }
    }

    var icon: AppIcon {
        self == .platinum ? .trophy : .medal
    }
}

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

struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let tier: AchievementTier
    let unlockedAt: String?
    var isSecret = false

    var isUnlocked: Bool {
        unlockedAt != nil
    }

    var isHidden: Bool {
        isSecret && !isUnlocked
    }

    var displayTitle: String {
        isHidden ? "Hidden achievement" : title
    }

    var displayDetail: String {
        isHidden ? "Keep playing to reveal this one." : detail
    }
}

struct GameAchievements: Identifiable {
    let id = UUID()
    let title: String
    let platform: String
    let coverStart: Color
    let coverEnd: Color
    let achievements: [Achievement]

    var total: Int {
        achievements.count
    }

    var unlockedCount: Int {
        achievements.count(where: \.isUnlocked)
    }

    var fraction: Double {
        total == 0 ? 0 : Double(unlockedCount) / Double(total)
    }

    var percent: Int {
        Int((fraction * 100).rounded())
    }

    var isComplete: Bool {
        total > 0 && unlockedCount == total
    }

    var hasPlatinum: Bool {
        achievements.contains { $0.tier == .platinum && $0.isUnlocked }
    }
}

extension [GameAchievements] {
    var unlockedTotal: Int {
        reduce(0) { $0 + $1.unlockedCount }
    }

    var achievementTotal: Int {
        reduce(0) { $0 + $1.total }
    }

    var platinumCount: Int {
        count(where: \.hasPlatinum)
    }

    var completedCount: Int {
        count(where: \.isComplete)
    }

    var unlockedFraction: Double {
        achievementTotal == 0 ? 0 : Double(unlockedTotal) / Double(achievementTotal)
    }
}
