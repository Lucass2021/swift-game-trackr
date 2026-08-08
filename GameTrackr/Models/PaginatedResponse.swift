import Foundation

struct PaginatedResponse<T: Decodable>: Decodable {
    let data: [T]
    let currentPage: Int
    let lastPage: Int
    let perPage: Int
    let total: Int

    enum CodingKeys: String, CodingKey {
        case data
        case currentPage = "current_page"
        case lastPage = "last_page"
        case perPage = "per_page"
        case total
    }
}
