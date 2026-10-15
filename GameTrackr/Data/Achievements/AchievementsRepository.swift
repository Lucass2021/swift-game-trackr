protocol AchievementsRepository: Sendable {
    func fetchAchievementGames(page: Int, perPage: Int) async throws -> Page<GameAchievements>
    func fetchAchievementsSummary() async throws -> AchievementsSummary
}
