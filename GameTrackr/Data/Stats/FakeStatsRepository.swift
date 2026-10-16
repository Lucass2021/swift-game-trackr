actor FakeStatsRepository: StatsRepository {
    private(set) var fetchCount = 0
    private let stats: UserStats
    private var failure: Error?
    private let latency: Duration

    init(
        stats: UserStats = StatsMockData.stats,
        failure: Error? = nil,
        latency: Duration = FakeLatency.responseDelay
    ) {
        self.stats = stats
        self.failure = failure
        self.latency = latency
    }

    func fetchStats() async throws -> UserStats {
        fetchCount += 1
        let error = failure
        try await Task.sleep(for: latency)
        if let error { throw error }
        return stats
    }

    func setFailure(_ error: Error?) {
        failure = error
    }
}
