import Foundation
import Testing
@testable import GameTrackr

struct APIErrorTests {
    @Test func mapsTheStatusCodesTheBackendActuallyReturns() {
        #expect(APIError(statusCode: 401).isUnauthorized)
        #expect(APIError(statusCode: 404).isNotFound)
        #expect(APIError(statusCode: 500).isServerError)
        #expect(APIError(statusCode: 503).isServerError)
    }

    @Test func fallsBackToUnknownForAnythingUnmapped() {
        guard case let .unknown(code) = APIError(statusCode: 418) else {
            Issue.record("expected .unknown")
            return
        }
        #expect(code == 418)
    }

    @Test func keepsTheRetryAfterHeaderInTheRateLimitMessage() {
        #expect(APIError(statusCode: 429, retryAfter: 30).localizedDescription.contains("30s"))
        #expect(APIError(statusCode: 429).localizedDescription == "Too many attempts. Please wait a moment.")
    }

    @Test func surfacesTheServerMessageForTheCasesThatCarryOne() {
        #expect(APIError.badRequest("Invalid code.").localizedDescription == "Invalid code.")
        #expect(APIError.conflict("Already in your library.").localizedDescription == "Already in your library.")
        #expect(APIError.validation("The email has already been taken.").localizedDescription
            == "The email has already been taken.")
    }

    @Test func usesAGenericMessageForTheCasesThatDoNot() {
        #expect(APIError.forbidden("only the author").localizedDescription == "You don't have permission to do that.")
        #expect(APIError.unauthorized.localizedDescription == "Invalid email or password.")
        #expect(APIError.networkFailure.localizedDescription.contains("No internet connection"))
        #expect(APIError.decodingFailure.localizedDescription == "Unexpected response from the server.")
        #expect(APIError.unknown(statusCode: 418).localizedDescription.contains("418"))
    }
}

private extension APIError {
    var isUnauthorized: Bool {
        if case .unauthorized = self { return true }
        return false
    }

    var isNotFound: Bool {
        if case .notFound = self { return true }
        return false
    }

    var isServerError: Bool {
        if case .serverError = self { return true }
        return false
    }
}
