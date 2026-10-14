import Foundation

struct ProfileColorDTO: Decodable {
    let key: String
    let name: String
    let hex: String
}

struct ProfileColorsResponse: Decodable {
    let message: String?
    let data: [ProfileColorDTO]
}

struct UpdateProfileRequest: Encodable {
    let name: String
    let username: String
    let profileColor: String

    enum CodingKeys: String, CodingKey {
        case name, username
        case profileColor = "profile_color"
    }
}
