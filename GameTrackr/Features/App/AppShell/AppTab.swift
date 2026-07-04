import SwiftUI

enum AppTab: CaseIterable, Identifiable {
    case home
    case library
    case community
    case profile

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .home: "Home"
        case .library: "Library"
        case .community: "Community"
        case .profile: "Profile"
        }
    }

    var icon: AppIcon {
        switch self {
        case .home: .home
        case .library: .library
        case .community: .community
        case .profile: .profile
        }
    }
}
