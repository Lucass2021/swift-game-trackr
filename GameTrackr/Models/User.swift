import Foundation

struct User: Decodable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let avatarUrl: String?
    let username: String?
    let profileColor: String?
    let bio: String?
    let visibility: ProfileVisibility
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name, email, username, bio, visibility
        case avatarUrl = "avatar_url"
        case profileColor = "profile_color"
        case createdAt = "created_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
        avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        profileColor = try container.decodeIfPresent(String.self, forKey: .profileColor)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        visibility = try ProfileVisibility(apiValue: container.decodeIfPresent(String.self, forKey: .visibility))
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt).flatMap(Self.parseDate)
    }

    private static func parseDate(_ value: String) -> Date? {
        try? Date(value, strategy: .iso8601.year().month().day().time(includingFractionalSeconds: true))
    }
}
