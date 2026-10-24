enum ProfileMenuItem: CaseIterable, Hashable {
    case editProfile
    case stats
    case achievements
    case settings
    case help
    case about

    var icon: AppIcon {
        switch self {
        case .editProfile: .editProfile
        case .stats: .chart
        case .achievements: .medal
        case .settings: .settings
        case .help: .help
        case .about: .info
        }
    }

    var title: String {
        switch self {
        case .editProfile: "Edit profile"
        case .stats: "My stats"
        case .achievements: "Achievements"
        case .settings: "Settings"
        case .help: "Help & feedback"
        case .about: "About"
        }
    }
}
