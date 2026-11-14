import Foundation

nonisolated struct ForgotPasswordRequest: Encodable {
    let email: String
    let client = "mobile"
}
