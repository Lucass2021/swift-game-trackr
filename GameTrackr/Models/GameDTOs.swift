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

struct PlatformsResponse: Decodable {
    let message: String?
    let data: [GamePlatformDTO]
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

struct GameImageDTO: Decodable {
    let id: Int?
    let url: String?
}

struct GameNamedDTO: Decodable {
    let id: Int?
    let name: String?
    let slug: String?
}

struct GameCompanyDTO: Decodable {
    let name: String?
}

struct GameInvolvedCompanyDTO: Decodable {
    let company: GameCompanyDTO?
    let developer: Bool?
    let publisher: Bool?
}

struct GameReleaseDateDTO: Decodable {
    let date: Int?
    let human: String?
}

struct GameDetailPlatformDTO: Decodable {
    let name: String?
    let slug: String?
    let abbreviation: String?
}

struct GameDetailDTO: Decodable {
    let id: Int
    let name: String
    let slug: String?
    let summary: String?
    let storyline: String?
    let firstReleaseDate: Int?
    let totalRating: Double?
    let aggregatedRating: Double?
    let rating: Double?
    let cover: GameImageDTO?
    let artworks: [GameImageDTO]?
    let screenshots: [GameImageDTO]?
    let platforms: [GameDetailPlatformDTO]?
    let genres: [GameNamedDTO]?
    let themes: [GameNamedDTO]?
    let gameModes: [GameNamedDTO]?
    let playerPerspectives: [GameNamedDTO]?
    let gameEngines: [GameNamedDTO]?
    let involvedCompanies: [GameInvolvedCompanyDTO]?
    let releaseDates: [GameReleaseDateDTO]?

    enum CodingKeys: String, CodingKey {
        case id, name, slug, summary, storyline, rating, cover, artworks, screenshots, platforms, genres, themes
        case firstReleaseDate = "first_release_date"
        case totalRating = "total_rating"
        case aggregatedRating = "aggregated_rating"
        case gameModes = "game_modes"
        case playerPerspectives = "player_perspectives"
        case gameEngines = "game_engines"
        case involvedCompanies = "involved_companies"
        case releaseDates = "release_dates"
    }
}

struct GameDetailResponse: Decodable {
    let message: String?
    let data: GameDetailDTO
}
