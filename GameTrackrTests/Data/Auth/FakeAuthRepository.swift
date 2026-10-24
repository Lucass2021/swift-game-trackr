import Foundation
@testable import GameTrackr

actor FakeAuthRepository: AuthRepository {
    nonisolated let user = User(id: 1, name: "Player", email: "player@gametrackr.com")

    private(set) var loginCount = 0
    private(set) var lastEmail: String?
    private(set) var lastPassword: String?
    private(set) var lastLoginPassword: String?
    private(set) var lastGoogleToken: String?
    private(set) var registerCount = 0
    private(set) var lastName: String?
    private(set) var forgotPasswordCount = 0
    private(set) var verifyCount = 0
    private(set) var resetCount = 0
    private(set) var lastCode: String?
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
        lastLoginPassword = password
        try await Task.sleep(for: latency)
        if let failure { throw failure }
        return user
    }

    func register(
        name: String,
        email: String,
        password: String,
        passwordConfirmation _: String
    ) async throws -> User {
        registerCount += 1
        lastName = name
        lastEmail = email
        lastPassword = password
        try await Task.sleep(for: latency)
        if let failure { throw failure }
        return user
    }

    func signInWithGoogle(token: String) async throws -> User {
        lastGoogleToken = token
        if let failure { throw failure }
        return user
    }

    func validate() async throws -> User {
        user
    }

    func forgotPassword(email: String) async throws {
        forgotPasswordCount += 1
        lastEmail = email
        try await Task.sleep(for: latency)
        if let failure { throw failure }
    }

    func verifyResetCode(email: String, code: String) async throws {
        verifyCount += 1
        lastEmail = email
        lastCode = code
        try await Task.sleep(for: latency)
        if let failure { throw failure }
    }

    func resetPassword(email: String, code: String, newPassword: String) async throws {
        resetCount += 1
        lastEmail = email
        lastCode = code
        lastPassword = newPassword
        try await Task.sleep(for: latency)
        if let failure { throw failure }
    }
}
