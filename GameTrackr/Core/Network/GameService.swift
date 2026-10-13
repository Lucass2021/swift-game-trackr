import Foundation

struct GameService {
    static let shared = GameService()

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
}
