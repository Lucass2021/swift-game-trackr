import Foundation

protocol AuthServicing: Sendable {
    func register(name: String, email: String, password: String, passwordConfirmation: String) async throws -> AuthResponse
    func login(email: String, password: String) async throws -> AuthResponse
    func forgotPassword(email: String) async throws -> String
    func verifyResetCode(email: String, code: String) async throws -> String
    func resetPassword(resetToken: String, newPassword: String) async throws
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

    func forgotPassword(email: String) async throws -> String {
        // # TODO: Implement forgot password API call
        try await Task.sleep(for: .milliseconds(800))
        return "We sent a 6-digit code to \(email)"
    }

    func verifyResetCode(email _: String, code _: String) async throws -> String {
        // # TODO: Implement verify reset code API call
        try await Task.sleep(for: .milliseconds(800))
        return UUID().uuidString
    }

    func resetPassword(resetToken _: String, newPassword _: String) async throws {
        // # TODO: Implement reset password API call
        try await Task.sleep(for: .milliseconds(800))
    }
}
