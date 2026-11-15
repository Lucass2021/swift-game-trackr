import SwiftUI

nonisolated extension NotificationIconKind {
    var tint: Color {
        switch self {
        case .like, .achievement: .appPrimary
        case .message: .appTextSecondary
        }
    }
}

extension NotificationIconKind {
    var icon: AppIcon {
        switch self {
        case .like: .like
        case .achievement: .medal
        case .message: .envelope
        }
    }
}
