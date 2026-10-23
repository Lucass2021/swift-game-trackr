import Foundation

actor FakeProfileRepository: ProfileRepository {
    private(set) var fetchColorsCount = 0
    private(set) var updateCount = 0
    private(set) var user: User
    private let colors: [ProfileColor]
    private var failure: Error?
    private let latency: Duration

    init(
        colors: [ProfileColor] = ProfileMockData.colors,
        user: User = ProfileMockData.user,
        failure: Error? = nil,
        latency: Duration = FakeLatency.responseDelay
    ) {
        self.colors = colors
        self.user = user
        self.failure = failure
        self.latency = latency
    }

    func fetchColors() async throws -> [ProfileColor] {
        fetchColorsCount += 1
        try await respond()
        return colors
    }

    func updateProfile(
        name: String,
        username: String,
        profileColor: String,
        bio: String,
        visibility: ProfileVisibility
    ) async throws -> User {
        updateCount += 1
        try await respond()
        user = User(
            id: user.id,
            name: name,
            email: user.email,
            avatarUrl: user.avatarUrl,
            username: username,
            profileColor: profileColor,
            bio: bio,
            visibility: visibility,
            createdAt: user.createdAt
        )
        return user
    }

    func setFailure(_ error: Error?) {
        failure = error
    }

    private func respond() async throws {
        try await Task.sleep(for: latency)
        if let failure { throw failure }
    }
}
