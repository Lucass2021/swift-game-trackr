protocol GameRepository: Sendable {
    func fetchNewReleases(limit: Int) async throws -> [Game]
    func fetchMostAnticipated(limit: Int) async throws -> [Game]
    func fetchGame(slug: String) async throws -> GameDetail
    func fetchAllNewReleases(page: Int, perPage: Int, search: String?, platformSlug: String?) async throws -> Page<Game>
    func fetchAllMostAnticipated(page: Int, perPage: Int, search: String?, platformSlug: String?) async throws
        -> Page<Game>
    func searchGames(page: Int, perPage: Int, search: String?, platformSlug: String?) async throws -> Page<Game>
    func fetchPlatforms() async throws -> [GamePlatform]
}
