struct RemoteGameRepository: GameRepository {
    private let apiClient: APIClient

    nonisolated init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    func fetchNewReleases(limit: Int) async throws -> [Game] {
        let response: GamesResponse = try await apiClient.request(.newReleases(limit: limit))
        return response.data.map(Game.init(dto:))
    }

    func fetchMostAnticipated(limit: Int) async throws -> [Game] {
        let response: GamesResponse = try await apiClient.request(.mostAnticipated(limit: limit))
        return response.data.map(Game.init(dto:))
    }

    func fetchGame(slug: String) async throws -> GameDetail {
        let response: GameDetailResponse = try await apiClient.request(.game(slug: slug))
        return GameDetail(dto: response.data)
    }
}
