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

    func fetchAllNewReleases(
        page: Int,
        perPage: Int,
        search: String?,
        platformSlug: String?
    ) async throws -> Page<Game> {
        let endpoint = Endpoint.allNewReleases(
            page: page,
            perPage: perPage,
            search: search,
            platforms: slugs(platformSlug)
        )
        let response: PaginatedGamesResponse = try await apiClient.request(endpoint)
        return toPage(response)
    }

    func fetchAllMostAnticipated(
        page: Int,
        perPage: Int,
        search: String?,
        platformSlug: String?
    ) async throws -> Page<Game> {
        let endpoint = Endpoint.allMostAnticipated(
            page: page,
            perPage: perPage,
            search: search,
            platforms: slugs(platformSlug)
        )
        let response: PaginatedGamesResponse = try await apiClient.request(endpoint)
        return toPage(response)
    }

    func searchGames(page: Int, perPage: Int, search: String?, platformSlug: String?) async throws -> Page<Game> {
        let endpoint = Endpoint.searchGames(
            page: page,
            perPage: perPage,
            search: search,
            platforms: slugs(platformSlug)
        )
        let response: PaginatedGamesResponse = try await apiClient.request(endpoint)
        return toPage(response)
    }

    func fetchPlatforms() async throws -> [GamePlatform] {
        let response: PlatformsResponse = try await apiClient.request(.platforms)
        return response.data.compactMap(GamePlatform.init(dto:))
    }

    private func slugs(_ platformSlug: String?) -> [String] {
        platformSlug.map { [$0] } ?? []
    }

    private func toPage(_ response: PaginatedGamesResponse) -> Page<Game> {
        Page(
            items: response.data.map { Game(dto: $0) },
            currentPage: response.meta.page,
            lastPage: response.meta.lastPage,
            total: response.meta.total
        )
    }
}
