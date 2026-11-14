import Foundation

nonisolated struct AuthResponse: Decodable {
    let token: String
    let user: User
    let message: String?
}
