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
    var avatarHex: String
    var visibility: ProfileVisibility
    private(set) var hasAttemptedSave = false
    private(set) var colors: [ProfileColor] = []
    private(set) var isSaving = false
    var errorMessage: String?

    private let original: Profile
    private let service = ProfileService.shared

    init(profile: Profile) {
        original = profile
        name = profile.name
        username = String(profile.username.drop { $0 == "@" })
        bio = profile.bio
        avatarHex = profile.avatarHex
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
            || avatarHex != original.avatarHex
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

    func loadColors() async {
        guard colors.isEmpty else { return }
        colors = await (try? service.fetchColors()) ?? []
    }

    func save() async -> (Profile, User)? {
        hasAttemptedSave = true
        guard canSave, !isSaving else { return nil }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        let user: User
        do {
            user = try await service.update(
                name: trimmedName,
                username: trimmedUsername,
                profileColor: avatarHex
            )
        } catch {
            errorMessage = error.userMessage()
            return nil
        }

        let profile = Profile(
            name: trimmedName,
            username: formattedUsername,
            bio: trimmedBio,
            joinedAt: original.joinedAt,
            avatarHex: avatarHex,
            stats: original.stats,
            visibility: visibility
        ).applying(user)

        return (profile, user)
    }
}
