import SwiftUI

struct UserProfile: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let username: String
    let avatarStart: Color
    let avatarEnd: Color
    var isFriend: Bool = false
}

extension UserProfile {
    init(handle: String, avatarStart: Color, avatarEnd: Color, isFriend: Bool = false) {
        let trimmed = handle.trimmingCharacters(in: .whitespaces)
        let hasAt = trimmed.hasPrefix("@")
        let display = hasAt ? String(trimmed.dropFirst()) : trimmed
        let username = hasAt
            ? trimmed
            : "@" + trimmed.lowercased().replacingOccurrences(of: " ", with: "")
        self.init(
            name: display,
            username: username,
            avatarStart: avatarStart,
            avatarEnd: avatarEnd,
            isFriend: isFriend
        )
    }
}
