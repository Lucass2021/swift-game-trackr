nonisolated enum AchievementFilter: CaseIterable, Identifiable {
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
}
