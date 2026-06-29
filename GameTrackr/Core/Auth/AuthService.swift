import Foundation

protocol AuthServicing: Sendable {
    func register(name: String, email: String, password: String, passwordConfirmation: String) async throws -> AuthResponse
    func login(email: String, password: String) async throws -> AuthResponse
    func forgotPassword(email: String) async throws
    func verifyResetCode(email: String, code: String) async throws
    func resetPassword(email: String, code: String, newPassword: String) async throws
}

struct AuthService: AuthServicing {
    static let live = AuthService()

    func register(name: String, email: String, password: String, passwordConfirmation: String) async throws -> AuthResponse {
        let body = RegisterRequest(
            name: name,
            email: email,
            password: password,
            passwordConfirmation: passwordConfirmation
        )
        return try await APIClient.shared.request(.register, body: body)
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        let body = LoginRequest(email: email, password: password)
        return try await APIClient.shared.request(.login, body: body)
    }

    func forgotPassword(email: String) async throws {
        let body = ForgotPasswordRequest(email: email)
        let _: MessageResponse = try await APIClient.shared.request(.forgotPassword, body: body)
    }

    func verifyResetCode(email: String, code: String) async throws {
        let body = VerifyResetCodeRequest(email: email, code: code)
        let _: MessageResponse = try await APIClient.shared.request(.verifyResetCode, body: body)
    }

    func resetPassword(email: String, code: String, newPassword: String) async throws {
        let body = ResetPasswordRequest(
            email: email,
            code: code,
            password: newPassword,
            passwordConfirmation: newPassword
        )
        let _: MessageResponse = try await APIClient.shared.request(.resetPassword, body: body)
    }
}
