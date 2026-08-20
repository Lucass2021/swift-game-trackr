import Foundation

struct GameCoverDTO: Decodable {
    let id: Int?
    let url: String?
}

struct GamePlatformDTO: Decodable {
    let id: Int?
    let name: String?
    let slug: String?
}

struct GameDTO: Decodable {
    let id: Int
    let name: String
    let slug: String?
    let summary: String?
    let firstReleaseDate: Int?
    let totalRating: Double?
    let rating: Double?
    let cover: GameCoverDTO?
    let platforms: [GamePlatformDTO]?

    enum CodingKeys: String, CodingKey {
        case id, name, slug, summary, rating, cover, platforms
        case firstReleaseDate = "first_release_date"
        case totalRating = "total_rating"
    }
}

struct GamesResponse: Decodable {
    let message: String?
    let data: [GameDTO]
}

struct GamesMeta: Decodable {
    let page: Int
    let perPage: Int
    let total: Int
    let lastPage: Int
    let hasMore: Bool

    enum CodingKeys: String, CodingKey {
        case page, total
        case perPage = "per_page"
        case lastPage = "last_page"
        case hasMore = "has_more"
    }
}

struct PaginatedGamesResponse: Decodable {
    let message: String?
    let data: [GameDTO]
    let meta: GamesMeta

    var page: PaginatedResponse<GameDTO> {
        PaginatedResponse(
            data: data,
            currentPage: meta.page,
            lastPage: meta.lastPage,
            perPage: meta.perPage,
            total: meta.total
        )
    }
}
