import Foundation

struct ResetPasswordRequest: Encodable {
    let email: String
    let code: String
    let password: String
    let passwordConfirmation: String
    let client = "mobile"

    enum CodingKeys: String, CodingKey {
        case email, code, password, client
        case passwordConfirmation = "password_confirmation"
    }
}
