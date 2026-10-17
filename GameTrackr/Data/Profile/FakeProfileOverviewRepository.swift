import Foundation

actor FakeProfileOverviewRepository: ProfileOverviewRepository {
    private(set) var fetchCount = 0
    private(set) var setFriendCount = 0
    private let myOverview: ProfileOverview
    private let userOverview: ProfileOverview
    private let userBio: String
    private let userJoinedAt: Date?
    private var friendUsernames: Set<String>
    private var failure: Error?
    private let latency: Duration

    init(
        myOverview: ProfileOverview = ProfileMockData.overview,
        userOverview: ProfileOverview = UserProfileMockData.overview,
        userBio: String = UserProfileMockData.bio,
        userJoinedAt: Date? = UserProfileMockData.joinedAt,
        friendUsernames: Set<String> = [],
        failure: Error? = nil,
        latency: Duration = FakeLatency.responseDelay
    ) {
        self.myOverview = myOverview
        self.userOverview = userOverview
        self.userBio = userBio
        self.userJoinedAt = userJoinedAt
        self.friendUsernames = friendUsernames
        self.failure = failure
        self.latency = latency
    }

    func fetchMyOverview() async throws -> ProfileOverview {
        fetchCount += 1
        try await respond()
        return myOverview
    }

    func fetchUserOverview(username: String) async throws -> UserOverview {
        fetchCount += 1
        try await respond()
        return UserOverview(
            bio: userBio,
            joinedAt: userJoinedAt,
            isFriend: friendUsernames.contains(username),
            overview: userOverview
        )
    }

    func setFriend(username: String, isFriend: Bool) async throws {
        setFriendCount += 1
        try await respond()
        if isFriend {
            friendUsernames.insert(username)
        } else {
            friendUsernames.remove(username)
        }
    }

    func isFriend(_ username: String) -> Bool {
        friendUsernames.contains(username)
    }

    func setFailure(_ error: Error?) {
        failure = error
    }

    private func respond() async throws {
        let error = failure
        try await Task.sleep(for: latency)
        if let error { throw error }
    }
}
