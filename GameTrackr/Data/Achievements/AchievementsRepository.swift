protocol AchievementsRepository: Sendable {
    func fetchAchievementGames(filter: AchievementFilter, page: Int, perPage: Int) async throws
        -> Page<GameAchievements>
    func fetchAchievementsSummary() async throws -> AchievementsSummary
    func fetchGameAchievements(id: Int) async throws -> GameAchievements
}
