import Foundation

struct User: Decodable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let avatarUrl: String?
    let username: String?
    let profileColor: String?

    enum CodingKeys: String, CodingKey {
        case id, name, email, username
        case avatarUrl = "avatar_url"
        case profileColor = "profile_color"
    }
}
