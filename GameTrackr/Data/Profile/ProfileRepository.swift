protocol ProfileRepository: Sendable {
    func fetchColors() async throws -> [ProfileColor]
    func updateProfile(
        name: String,
        username: String,
        profileColor: String,
        bio: String,
        visibility: ProfileVisibility
    ) async throws -> User
}
