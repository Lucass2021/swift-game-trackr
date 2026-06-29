import Foundation

struct ForgotPasswordRequest: Encodable {
    let email: String
    let client = "mobile"
}
