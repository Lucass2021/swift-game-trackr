struct FakeAchievementsRepository: AchievementsRepository {
    func fetchAchievementGames(page: Int, perPage: Int) async throws -> Page<GameAchievements> {
        try await Task.sleep(for: FakeLatency.responseDelay)
        return fakePage(items: AchievementsMockData.games, page: page, perPage: perPage)
    }

    func fetchAchievementsSummary() async throws -> AchievementsSummary {
        try await Task.sleep(for: FakeLatency.responseDelay)
        return AchievementsSummary(games: AchievementsMockData.games)
    }

    func fetchGameAchievements(id: Int) async throws -> GameAchievements {
        try await Task.sleep(for: FakeLatency.responseDelay)
        guard let game = AchievementsMockData.games.first(where: { $0.id == id }) else {
            throw APIError.notFound
        }
        return game
    }
}
