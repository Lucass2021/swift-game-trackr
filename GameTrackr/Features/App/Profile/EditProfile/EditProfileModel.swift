import SwiftUI

@MainActor
@Observable
final class EditProfileModel {
    static let nameLimit = 50
    static let usernameLimit = 20
    static let bioLimit = 160

    private static let usernameAllowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789_")

    var name: String
    var username: String
    var bio: String
    var palette: AvatarPalette
    var visibility: ProfileVisibility
    private(set) var hasAttemptedSave = false

    private let original: Profile

    init(profile: Profile) {
        original = profile
        name = profile.name
        username = String(profile.username.drop { $0 == "@" })
        bio = profile.bio
        palette = AvatarPalette.matching(start: profile.avatarStart, end: profile.avatarEnd)
        visibility = profile.visibility
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedUsername: String {
        username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private var trimmedBio: String {
        bio.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var nameError: String? {
        if trimmedName.isEmpty { return "Name is required" }
        if trimmedName.count < 3 { return "At least 3 characters" }
        if trimmedName.count > Self.nameLimit { return "Name must be under \(Self.nameLimit) characters" }
        return nil
    }

    var usernameError: String? {
        if trimmedUsername.isEmpty { return "Username is required" }
        if trimmedUsername.count < 3 { return "At least 3 characters" }
        if trimmedUsername.count > Self.usernameLimit {
            return "Username must be under \(Self.usernameLimit) characters"
        }
        if trimmedUsername.unicodeScalars.contains(where: { !Self.usernameAllowed.contains($0) }) {
            return "Only letters, numbers and underscore"
        }
        return nil
    }

    var bioError: String? {
        trimmedBio.count > Self.bioLimit ? "Bio must be under \(Self.bioLimit) characters" : nil
    }

    var canSave: Bool {
        nameError == nil && usernameError == nil && bioError == nil
    }

    var bioRemaining: Int {
        Self.bioLimit - bio.count
    }

    var hasChanges: Bool {
        trimmedName != original.name
            || formattedUsername != original.username
            || trimmedBio != original.bio
            || palette != AvatarPalette.matching(start: original.avatarStart, end: original.avatarEnd)
            || visibility != original.visibility
    }

    var previewName: String {
        trimmedName.isEmpty ? original.name : trimmedName
    }

    var previewUsername: String {
        trimmedUsername.isEmpty ? original.username : formattedUsername
    }

    private var formattedUsername: String {
        "@\(trimmedUsername)"
    }

    func visibleError(_ error: String?) -> String? {
        hasAttemptedSave ? error : nil
    }

    func save() -> Profile? {
        hasAttemptedSave = true
        guard canSave else { return nil }

        return Profile(
            name: trimmedName,
            username: formattedUsername,
            bio: trimmedBio,
            joinedAt: original.joinedAt,
            avatarStart: palette.start,
            avatarEnd: palette.end,
            stats: original.stats,
            visibility: visibility
        )
    }
}
