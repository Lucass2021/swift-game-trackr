import Foundation

struct RemoteAuthRepository: AuthRepository {
    private let apiClient: APIClient
    private let tokenStore: TokenStore

    nonisolated init(apiClient: APIClient = .shared, tokenStore: TokenStore = KeychainTokenStore()) {
        self.apiClient = apiClient
        self.tokenStore = tokenStore
    }

    func login(email: String, password: String) async throws -> User {
        let body = LoginRequest(email: email, password: password)
        do {
            let response: AuthResponse = try await apiClient.request(.login, body: body)
            tokenStore.save(response.token)
            return response.user
        } catch APIError.forbidden {
            throw APIError.unauthorized
        }
    }

    func register(name: String, email: String, password: String, passwordConfirmation: String) async throws -> User {
        let body = RegisterRequest(
            name: name,
            email: email,
            password: password,
            passwordConfirmation: passwordConfirmation
        )
        let response: AuthResponse = try await apiClient.request(.register, body: body)
        tokenStore.save(response.token)
        return response.user
    }

    func signInWithGoogle(token: String) async throws -> User {
        tokenStore.save(token)
        do {
            return try await validate()
        } catch {
            tokenStore.clear()
            throw error
        }
    }

    func validate() async throws -> User {
        let response: ValidateResponse = try await apiClient.request(.me)
        return response.user
    }

    func forgotPassword(email: String) async throws {
        let body = ForgotPasswordRequest(email: email)
        let _: MessageResponse = try await apiClient.request(.forgotPassword, body: body)
    }

    func verifyResetCode(email: String, code: String) async throws {
        let body = VerifyResetCodeRequest(email: email, code: code)
        let _: MessageResponse = try await apiClient.request(.verifyResetCode, body: body)
    }

    func resetPassword(email: String, code: String, newPassword: String) async throws {
        let body = ResetPasswordRequest(
            email: email,
            code: code,
            password: newPassword,
            passwordConfirmation: newPassword
        )
        let _: MessageResponse = try await apiClient.request(.resetPassword, body: body)
    }
}
