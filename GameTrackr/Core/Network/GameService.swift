import Foundation

struct GameService {
    static let shared = GameService()

    func fetchSlider(_ scope: SearchScope, limit: Int = 10) async throws -> [GameDTO] {
        let endpoint: Endpoint = scope == .mostAnticipated
            ? .mostAnticipated(limit: limit)
            : .newReleases(limit: limit)
        let response: GamesResponse = try await APIClient.shared.request(endpoint)
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
        let response: PaginatedGamesResponse = try await APIClient.shared.request(endpoint)
        return response.page
    }

    func fetchPlatforms() async throws -> [GamePlatform] {
        let response: PlatformsResponse = try await APIClient.shared.request(.platforms)
        return response.data.compactMap(GamePlatform.init(dto:))
    }

    func fetchGame(slug: String) async throws -> GameDetailDTO {
        let response: GameDetailResponse = try await APIClient.shared.request(.game(slug: slug))
        return response.data
    }
}
