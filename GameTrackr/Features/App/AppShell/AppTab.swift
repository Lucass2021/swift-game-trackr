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

    var icon: String {
        switch self {
        case .home: "house"
        case .library: "square.stack"
        case .community: "person.3"
        case .profile: "person"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home: "house.fill"
        case .library: "square.stack.fill"
        case .community: "person.3.fill"
        case .profile: "person.fill"
        }
    }
}
