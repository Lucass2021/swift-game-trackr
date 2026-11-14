import Foundation

nonisolated struct LoginRequest: Encodable {
    let email: String
    let password: String
}
