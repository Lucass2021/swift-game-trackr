struct FakeAchievementsRepository: AchievementsRepository {
    func fetchAchievementGames(page: Int, perPage: Int) async throws -> Page<GameAchievements> {
        try await Task.sleep(for: FakeLatency.responseDelay)
        return fakePage(items: AchievementsMockData.games, page: page, perPage: perPage)
    }

    func fetchAchievementsSummary() async throws -> AchievementsSummary {
        try await Task.sleep(for: FakeLatency.responseDelay)
        return AchievementsSummary(games: AchievementsMockData.games)
    }
}
