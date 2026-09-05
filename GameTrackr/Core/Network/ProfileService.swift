import Foundation

private struct UpdateProfileRequest: Encodable {
    let name: String
    let username: String
    let profileColor: String

    enum CodingKeys: String, CodingKey {
        case name, username
        case profileColor = "profile_color"
    }
}

protocol ProfileServicing: Sendable {
    func fetchColors() async throws -> [ProfileColor]
    func update(name: String, username: String, profileColor: String) async throws -> User
}

struct ProfileService: ProfileServicing {
    static let live = ProfileService()

    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchColors() async throws -> [ProfileColor] {
        let response: ProfileColorsResponse = try await client.request(.profileColors)
        return response.data
    }

    func update(name: String, username: String, profileColor: String) async throws -> User {
        let body = UpdateProfileRequest(name: name, username: username, profileColor: profileColor)
        let response: ValidateResponse = try await client.request(.updateProfile, body: body)
        return response.user
    }
}
