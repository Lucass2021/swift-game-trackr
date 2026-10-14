struct RemoteProfileRepository: ProfileRepository {
    private let apiClient: APIClient

    nonisolated init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    func fetchColors() async throws -> [ProfileColor] {
        let response: ProfileColorsResponse = try await apiClient.request(.profileColors)
        return response.data.map { ProfileColor(dto: $0) }
    }

    func updateProfile(name: String, username: String, profileColor: String) async throws -> User {
        let body = UpdateProfileRequest(name: name, username: username, profileColor: profileColor)
        let response: ValidateResponse = try await apiClient.request(.updateProfile, body: body)
        return response.user
    }
}
