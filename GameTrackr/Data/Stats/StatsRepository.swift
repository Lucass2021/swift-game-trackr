protocol StatsRepository: Sendable {
    func fetchStats() async throws -> UserStats
}
