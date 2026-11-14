import Foundation

nonisolated struct ProfileColorDTO: Decodable {
    let key: String
    let name: String
    let hex: String
}

nonisolated struct ProfileColorsResponse: Decodable {
    let message: String?
    let data: [ProfileColorDTO]
}

nonisolated struct UpdateProfileRequest: Encodable {
    let name: String
    let username: String
    let profileColor: String
    let bio: String
    let visibility: String

    enum CodingKeys: String, CodingKey {
        case name, username, bio, visibility
        case profileColor = "profile_color"
    }
}
