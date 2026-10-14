protocol ProfileRepository: Sendable {
    func fetchColors() async throws -> [ProfileColor]
    func updateProfile(name: String, username: String, profileColor: String) async throws -> User
}
