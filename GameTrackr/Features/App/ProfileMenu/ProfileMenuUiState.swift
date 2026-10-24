import Foundation

struct ProfileMenuUiState: Equatable {
    let isGuest: Bool
    let name: String
    let subtitle: String

    init(isGuest: Bool, userName: String?, email: String?) {
        self.isGuest = isGuest
        name = isGuest ? "Guest" : userName?.trimmingCharacters(in: .whitespaces) ?? ""
        subtitle = isGuest ? "Not signed in" : email?.trimmingCharacters(in: .whitespaces) ?? ""
    }

    var accountItems: [ProfileMenuItem] {
        isGuest ? [] : [.editProfile, .stats, .achievements]
    }

    var appItems: [ProfileMenuItem] {
        isGuest ? [.help, .about] : [.settings, .help, .about]
    }
}
