actor FakeProfileOverviewRepository: ProfileOverviewRepository {
    private(set) var fetchCount = 0
    private let myOverview: ProfileOverview
    private let userOverview: ProfileOverview
    private var failure: Error?
    private let latency: Duration

    init(
        myOverview: ProfileOverview = ProfileMockData.overview,
        userOverview: ProfileOverview = UserProfileMockData.overview,
        failure: Error? = nil,
        latency: Duration = FakeLatency.responseDelay
    ) {
        self.myOverview = myOverview
        self.userOverview = userOverview
        self.failure = failure
        self.latency = latency
    }

    func fetchMyOverview() async throws -> ProfileOverview {
        try await respond()
        return myOverview
    }

    func fetchUserOverview(username _: String) async throws -> ProfileOverview {
        try await respond()
        return userOverview
    }

    func setFailure(_ error: Error?) {
        failure = error
    }

    private func respond() async throws {
        fetchCount += 1
        let error = failure
        try await Task.sleep(for: latency)
        if let error { throw error }
    }
}
