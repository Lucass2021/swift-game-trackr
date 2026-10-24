import Foundation
@testable import GameTrackr

actor FakeAuthRepository: AuthRepository {
    nonisolated let user = User(id: 1, name: "Player", email: "player@gametrackr.com")

    private(set) var loginCount = 0
    private(set) var lastEmail: String?
    private(set) var lastPassword: String?
    private(set) var lastGoogleToken: String?
    private var failure: Error?
    private let latency: Duration

    init(failure: Error? = nil, latency: Duration = .zero) {
        self.failure = failure
        self.latency = latency
    }

    func setFailure(_ error: Error?) {
        failure = error
    }

    func login(email: String, password: String) async throws -> User {
        loginCount += 1
        lastEmail = email
        lastPassword = password
        try await Task.sleep(for: latency)
        if let failure { throw failure }
        return user
    }

    func register(
        name _: String,
        email _: String,
        password _: String,
        passwordConfirmation _: String
    ) async throws -> User {
        user
    }

    func signInWithGoogle(token: String) async throws -> User {
        lastGoogleToken = token
        if let failure { throw failure }
        return user
    }

    func validate() async throws -> User {
        user
    }

    func forgotPassword(email _: String) async throws {}

    func verifyResetCode(email _: String, code _: String) async throws {}

    func resetPassword(email _: String, code _: String, newPassword _: String) async throws {}
}
