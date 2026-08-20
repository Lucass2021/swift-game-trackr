import Foundation

struct GameService {
    static let shared = GameService()

    func fetchNewReleases(limit: Int = 10) async throws -> [GameDTO] {
        let response: GamesResponse = try await APIClient.shared.request(.newReleases(limit: limit))
        return response.data
    }

    func fetchAllNewReleases(page: Int, perPage: Int = 20) async throws -> PaginatedResponse<GameDTO> {
        let response: PaginatedGamesResponse = try await APIClient.shared.request(
            .allNewReleases(page: page, perPage: perPage)
        )
        return response.page
    }
}
