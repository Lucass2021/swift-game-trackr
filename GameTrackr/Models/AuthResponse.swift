import Foundation

struct AuthResponse: Decodable {
    let token: String
    let user: User
    let message: String?
}
