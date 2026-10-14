struct FakeStatsRepository: StatsRepository {
    private enum Constants {
        static let responseDelay = Duration.milliseconds(600)
    }

    func fetchStats() async throws -> UserStats {
        try await Task.sleep(for: Constants.responseDelay)
        return StatsMockData.stats
    }
}
