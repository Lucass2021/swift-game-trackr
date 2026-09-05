import Foundation

protocol GameServicing: Sendable {
    func fetchSlider(_ scope: SearchScope, limit: Int) async throws -> [GameDTO]
    func fetchFeed(
        _ scope: SearchScope,
        page: Int,
        perPage: Int,
        search: String?,
        platform: GamePlatform?
    ) async throws -> PaginatedResponse<GameDTO>
    func fetchPlatforms() async throws -> [GamePlatform]
    func fetchGame(slug: String) async throws -> GameDetailDTO
}

struct GameService: GameServicing {
    static let live = GameService()

    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchSlider(_ scope: SearchScope, limit: Int = 10) async throws -> [GameDTO] {
        let endpoint: Endpoint = scope == .mostAnticipated
            ? .mostAnticipated(limit: limit)
            : .newReleases(limit: limit)
        let response: GamesResponse = try await client.request(endpoint)
        return response.data
    }

    func fetchFeed(
        _ scope: SearchScope,
        page: Int,
        perPage: Int = 20,
        search: String? = nil,
        platform: GamePlatform? = nil
    ) async throws -> PaginatedResponse<GameDTO> {
        let slugs = platform.map { [$0.slug] } ?? []
        let endpoint: Endpoint = switch scope {
        case .mostAnticipated:
            .allMostAnticipated(page: page, perPage: perPage, search: search, platforms: slugs)
        case .newReleases:
            .allNewReleases(page: page, perPage: perPage, search: search, platforms: slugs)
        case .all:
            .searchGames(page: page, perPage: perPage, search: search, platforms: slugs)
        }
        let response: PaginatedGamesResponse = try await client.request(endpoint)
        return response.page
    }

    func fetchPlatforms() async throws -> [GamePlatform] {
        let response: PlatformsResponse = try await client.request(.platforms)
        return response.data.compactMap(GamePlatform.init(dto:))
    }

    func fetchGame(slug: String) async throws -> GameDetailDTO {
        let response: GameDetailResponse = try await client.request(.game(slug: slug))
        return response.data
    }
}
