struct FakeStatsRepository: StatsRepository {
    func fetchStats() async throws -> UserStats {
        try await Task.sleep(for: FakeLatency.responseDelay)
        return StatsMockData.stats
    }
}
