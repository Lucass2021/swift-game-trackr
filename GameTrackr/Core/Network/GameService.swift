import Foundation

struct GameService {
    static let shared = GameService()

    func fetchNewReleases(limit: Int = 10) async throws -> [GameDTO] {
        let response: GamesResponse = try await APIClient.shared.request(.newReleases(limit: limit))
        return response.data
    }

    func fetchAllNewReleases(
        page: Int,
        perPage: Int = 20,
        search: String? = nil,
        platform: GamePlatform? = nil
    ) async throws -> PaginatedResponse<GameDTO> {
        let response: PaginatedGamesResponse = try await APIClient.shared.request(
            .allNewReleases(
                page: page,
                perPage: perPage,
                search: search,
                platforms: platform?.igdbSlugs ?? []
            )
        )
        return response.page
    }

    func fetchGame(slug: String) async throws -> GameDetailDTO {
        let response: GameDetailResponse = try await APIClient.shared.request(.game(slug: slug))
        return response.data
    }
}
