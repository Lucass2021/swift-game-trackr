import SwiftUI

enum AppIcon {
    case home
    case library
    case community
    case profile
    case discover
    case notifications
    case search
    case settings
    case envelope
    case eye
    case eyeSlash
    case check
    case success
    case shieldCheck
    case back
    case forward
    case brand
    case avatar
    case editProfile
    case medal
    case info
    case grid
    case list
    case help
    case like

    func image(filled: Bool = false) -> Image {
        Image(filled ? "\(glyph)-fill" : glyph)
    }

    private var glyph: String {
        switch self {
        case .home: "house"
        case .library: "stack"
        case .community: "users-three"
        case .profile: "user"
        case .discover: "compass"
        case .notifications: "bell"
        case .search: "magnifying-glass"
        case .settings: "gear"
        case .envelope: "envelope"
        case .eye: "eye"
        case .eyeSlash: "eye-slash"
        case .check: "check"
        case .success: "check-circle"
        case .shieldCheck: "shield-check"
        case .back: "caret-left"
        case .forward: "caret-right"
        case .brand: "game-controller"
        case .avatar: "user-circle"
        case .editProfile: "user-circle"
        case .medal: "medal"
        case .info: "info"
        case .grid: "squares-four"
        case .list: "list-bullets"
        case .help: "question"
        case .like: "heart"
        }
    }
}

struct AppIconView: View {
    let icon: AppIcon
    var filled = false
    var size: CGFloat = 22

    var body: some View {
        icon.image(filled: filled)
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .frame(width: size, height: size)
    }
}
