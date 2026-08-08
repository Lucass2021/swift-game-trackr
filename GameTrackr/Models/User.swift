import Foundation

struct User: Decodable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case avatarUrl = "avatar_url"
    }
}
