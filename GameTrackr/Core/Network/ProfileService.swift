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

struct ProfileService {
    static let shared = ProfileService()

    func fetchColors() async throws -> [ProfileColor] {
        let response: ProfileColorsResponse = try await APIClient.shared.request(.profileColors)
        return response.data
    }

    func update(name: String, username: String, profileColor: String) async throws -> User {
        let body = UpdateProfileRequest(name: name, username: username, profileColor: profileColor)
        let response: ValidateResponse = try await APIClient.shared.request(.updateProfile, body: body)
        return response.user
    }
}
