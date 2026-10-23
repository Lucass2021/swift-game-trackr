import Foundation

@MainActor
@Observable
final class EditProfileViewModel {
    static let nameMin = 3
    static let nameLimit = 50
    static let usernameMin = 3
    static let usernameLimit = 20
    static let bioLimit = 1000
    static let usernamePrefix = "@"

    private static let usernameAlphabet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789_")

    let original: Profile
    private(set) var name: String
    private(set) var username: String
    private(set) var bio: String
    private(set) var avatarHex: String
    private(set) var visibility: ProfileVisibility
    private(set) var colors: [ProfileColor] = []
    private(set) var isLoadingColors = false
    private(set) var colorsFailed = false
    private(set) var isSubmitted = false
    private(set) var isSaving = false
    private(set) var savedProfile: Profile?
    var toastMessage: String?

    private let repository: ProfileRepository

    init(profile: Profile, repository: ProfileRepository = RemoteProfileRepository()) {
        original = profile
        self.repository = repository
        name = profile.name
        username = String(profile.username.drop { String($0) == Self.usernamePrefix })
        bio = profile.bio
        avatarHex = profile.avatarHex
        visibility = profile.visibility
    }

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var normalizedUsername: String {
        username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    var trimmedBio: String {
        bio.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var bioRemaining: Int {
        Self.bioLimit - bio.count
    }

    var nameError: String? {
        isSubmitted ? Self.nameError(for: trimmedName) : nil
    }

    var usernameError: String? {
        isSubmitted ? Self.usernameError(for: normalizedUsername) : nil
    }

    var bioError: String? {
        isSubmitted ? Self.bioError(for: trimmedBio) : nil
    }

    var canSave: Bool {
        Self.nameError(for: trimmedName) == nil
            && Self.usernameError(for: normalizedUsername) == nil
            && Self.bioError(for: trimmedBio) == nil
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
        normalizedUsername.isEmpty ? original.username : formattedUsername
    }

    private var formattedUsername: String {
        Self.usernamePrefix + normalizedUsername
    }

    func onNameChange(_ value: String) {
        name = value
    }

    func onUsernameChange(_ value: String) {
        username = value
    }

    func onBioChange(_ value: String) {
        bio = value
    }

    func onAvatarColorChange(_ value: String) {
        avatarHex = value
    }

    func onVisibilityChange(_ value: ProfileVisibility) {
        visibility = value
    }

    func loadColorsIfNeeded() async {
        guard colors.isEmpty else { return }
        await loadColors()
    }

    func loadColors() async {
        guard !isLoadingColors else { return }
        isLoadingColors = true
        colorsFailed = false
        defer { isLoadingColors = false }
        do {
            colors = try await repository.fetchColors()
        } catch {
            colorsFailed = true
        }
    }

    func save(authStore: AuthStore) async -> Profile? {
        guard !isSaving, savedProfile == nil else { return nil }
        isSubmitted = true
        guard canSave else { return nil }

        isSaving = true
        toastMessage = nil
        defer { isSaving = false }

        let updated = updatedProfile()
        do {
            let user = try await repository.updateProfile(
                name: updated.name,
                username: normalizedUsername,
                profileColor: updated.avatarHex,
                bio: updated.bio,
                visibility: updated.visibility
            )
            authStore.updateUser(user)
            savedProfile = updated.applying(user)
            return savedProfile
        } catch {
            toastMessage = error.userMessage()
            return nil
        }
    }

    private func updatedProfile() -> Profile {
        var profile = original
        profile.name = trimmedName
        profile.username = formattedUsername
        profile.bio = trimmedBio
        profile.avatarHex = avatarHex
        profile.visibility = visibility
        return profile
    }

    private static func nameError(for name: String) -> String? {
        if name.isEmpty { return "Name is required" }
        if name.count < nameMin { return "At least \(nameMin) characters" }
        if name.count > nameLimit { return "Name must be at most \(nameLimit) characters" }
        return nil
    }

    private static func usernameError(for username: String) -> String? {
        if username.isEmpty { return "Username is required" }
        if username.count < usernameMin { return "At least \(usernameMin) characters" }
        if username.count > usernameLimit { return "Username must be at most \(usernameLimit) characters" }
        if username.unicodeScalars.contains(where: { !usernameAlphabet.contains($0) }) {
            return "Only letters, numbers and underscore"
        }
        return nil
    }

    private static func bioError(for bio: String) -> String? {
        bio.count > bioLimit ? "Bio must be at most \(bioLimit) characters" : nil
    }
}
