@testable import GameTrackr

final class FakeGoogleAuth: GoogleAuth {
    var result: Result<String, Error> = .success("google-token")
    private(set) var signInCount = 0

    func signIn() async throws -> String {
        signInCount += 1
        return try result.get()
    }
}
