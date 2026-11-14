import Foundation

nonisolated struct VerifyResetCodeRequest: Encodable {
    let email: String
    let code: String
}
