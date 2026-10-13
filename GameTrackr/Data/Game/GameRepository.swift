protocol GameRepository: Sendable {
    func fetchNewReleases(limit: Int) async throws -> [Game]
    func fetchMostAnticipated(limit: Int) async throws -> [Game]
    func fetchGame(slug: String) async throws -> GameDetail
}
