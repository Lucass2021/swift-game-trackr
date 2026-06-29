import Foundation

struct VerifyResetCodeRequest: Encodable {
    let email: String
    let code: String
}
