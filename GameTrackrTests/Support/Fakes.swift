import Foundation
@testable import GameTrackr

final class CallRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var counts: [String: Int] = [:]

    func record(_ key: String) {
        lock.withLock { counts[key, default: 0] += 1 }
    }

    func count(_ key: String) -> Int {
        lock.withLock { counts[key] ?? 0 }
    }
}

struct FakeGameService: GameServicing {
    let recorder = CallRecorder()
    var slider: [GameDTO] = []
    var feed = PaginatedResponse<GameDTO>(data: [], currentPage: 1, lastPage: 1, perPage: 20, total: 0)
    var platformList: [GamePlatform] = []
    var detail: GameDetailDTO?
    var failure: APIError?

    func fetchSlider(_: SearchScope, limit _: Int) async throws -> [GameDTO] {
        recorder.record("slider")
        if let failure { throw failure }
        return slider
    }

    func fetchFeed(
        _: SearchScope,
        page _: Int,
        perPage _: Int,
        search _: String?,
        platform _: GamePlatform?
    ) async throws -> PaginatedResponse<GameDTO> {
        recorder.record("feed")
        if let failure { throw failure }
        return feed
    }

    func fetchPlatforms() async throws -> [GamePlatform] {
        if let failure { throw failure }
        return platformList
    }

    func fetchGame(slug _: String) async throws -> GameDetailDTO {
        if let failure { throw failure }
        guard let detail else { throw APIError.notFound }
        return detail
    }
}

struct FakeAuthService: AuthServicing {
    var response: AuthResponse?
    var failure: APIError?

    func register(
        name _: String,
        email _: String,
        password _: String,
        passwordConfirmation _: String
    ) async throws -> AuthResponse {
        try result()
    }

    func login(email _: String, password _: String) async throws -> AuthResponse {
        try result()
    }

    func forgotPassword(email _: String) async throws {
        if let failure { throw failure }
    }

    func verifyResetCode(email _: String, code _: String) async throws {
        if let failure { throw failure }
    }

    func resetPassword(email _: String, code _: String, newPassword _: String) async throws {
        if let failure { throw failure }
    }

    private func result() throws -> AuthResponse {
        if let failure { throw failure }
        guard let response else { throw APIError.unauthorized }
        return response
    }
}

@MainActor
final class FakeGoogleAuth: GoogleAuthenticating {
    var token = "google-token"
    var failure: Error?
    private(set) var signInCount = 0

    func signIn() async throws -> String {
        signInCount += 1
        if let failure { throw failure }
        return token
    }
}

enum TestData {
    static func game(id: Int, name: String, cover: String? = nil, releaseDate: Int? = nil) -> GameDTO {
        GameDTO(
            id: id,
            name: name,
            slug: name.lowercased().replacingOccurrences(of: " ", with: "-"),
            summary: nil,
            firstReleaseDate: releaseDate,
            totalRating: nil,
            rating: nil,
            cover: cover.map { GameCoverDTO(id: 1, url: $0) },
            platforms: nil
        )
    }

    static func user(id: Int = 1, name: String = "Lucas") -> User {
        User(
            id: id,
            name: name,
            email: "lucas@example.com",
            avatarUrl: nil,
            username: "lucas",
            profileColor: "#7C5CFF"
        )
    }

    static func authResponse(token: String = "jwt-token") -> AuthResponse {
        AuthResponse(token: token, user: user(), message: nil)
    }
}
