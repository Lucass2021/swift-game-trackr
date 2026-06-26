import Foundation

protocol AuthServicing: Sendable {
    func register(name: String, email: String, password: String, passwordConfirmation: String) async throws -> AuthResponse
    func login(email: String, password: String) async throws -> AuthResponse
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
}
