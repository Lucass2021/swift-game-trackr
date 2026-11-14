import Foundation
import Synchronization
import Testing
@testable import GameTrackr

private struct EmptyResponse: Decodable {}

private final class CallCounter: Sendable {
    private let count = Mutex(0)

    var value: Int {
        count.withLock { $0 }
    }

    func increment() {
        count.withLock { $0 += 1 }
    }
}

private final class SequenceTokenStore: TokenStore {
    private let tokens: Mutex<[String]>

    init(_ tokens: [String]) {
        self.tokens = Mutex(tokens)
    }

    func get() -> String? {
        tokens.withLock { $0.count > 1 ? $0.removeFirst() : $0.first }
    }

    func save(_ token: String) {
        tokens.withLock { $0 = [token] }
    }

    func clear() {
        tokens.withLock { $0 = [] }
    }
}

extension RepositoryTests {
    @MainActor
    struct APIClientTests {
        private static let httpOK = 200
        private static let httpUnauthorized = 401
        private static let httpTooManyRequests = 429
        private static let httpServerError = 500
        private static let mePath = "/profile/me"
        private static let refreshPath = "/auth/refresh"
        private static let spentToken = "spent.token.value"
        private static let refreshedToken = "refreshed.token.value"
        private static let rejectedBody = #"{"error":"The token has been blacklisted"}"#
        private static let refreshBody = #"{"token":"\#(refreshedToken)"}"#

        private let tokenStore = FakeTokenStore()
        private let refreshFailures = CallCounter()

        private func makeClient(tokenStore: TokenStore) async -> APIClient {
            StubURLProtocol.stub = nil
            StubURLProtocol.requests = []
            let client = APIClient(session: StubURLProtocol.makeSession(), tokenStore: tokenStore)
            let refreshFailures = refreshFailures
            await client.setRefreshFailureHandler { refreshFailures.increment() }
            return client
        }

        private func resetStubs() {
            StubURLProtocol.stubsByPath = [:]
            StubURLProtocol.failingPaths = []
        }

        private func failure(of client: APIClient) async -> String? {
            do {
                let _: EmptyResponse = try await client.request(.me)
                return nil
            } catch {
                return String(describing: error)
            }
        }

        private var refreshRequests: [URLRequest] {
            StubURLProtocol.requests.filter { $0.url?.path.hasSuffix(Self.refreshPath) == true }
        }

        @Test func refreshNetworkFailureKeepsTheSession() async {
            tokenStore.save(Self.spentToken)
            let client = await makeClient(tokenStore: tokenStore)
            StubURLProtocol.stubsByPath = [Self.mePath: .init(statusCode: Self.httpUnauthorized, body: "{}")]
            StubURLProtocol.failingPaths = [Self.refreshPath]
            defer { resetStubs() }

            #expect(await failure(of: client) == String(describing: APIError.networkFailure))

            #expect(refreshFailures.value == 0)
            #expect(tokenStore.get() == Self.spentToken)
        }

        @Test func refreshServerErrorKeepsTheSession() async {
            tokenStore.save(Self.spentToken)
            let client = await makeClient(tokenStore: tokenStore)
            StubURLProtocol.stubsByPath = [
                Self.mePath: .init(statusCode: Self.httpUnauthorized, body: "{}"),
                Self.refreshPath: .init(statusCode: Self.httpServerError, body: "{}")
            ]
            defer { resetStubs() }

            #expect(await failure(of: client) == String(describing: APIError.serverError))

            #expect(refreshFailures.value == 0)
            #expect(tokenStore.get() == Self.spentToken)
        }

        @Test func refreshRateLimitKeepsTheSession() async {
            tokenStore.save(Self.spentToken)
            let client = await makeClient(tokenStore: tokenStore)
            StubURLProtocol.stubsByPath = [
                Self.mePath: .init(statusCode: Self.httpUnauthorized, body: "{}"),
                Self.refreshPath: .init(statusCode: Self.httpTooManyRequests, body: "{}")
            ]
            defer { resetStubs() }

            #expect(await failure(of: client) == String(describing: APIError.rateLimited(retryAfter: nil)))

            #expect(refreshFailures.value == 0)
            #expect(tokenStore.get() == Self.spentToken)
        }

        @Test func rejectedRefreshEndsTheSession() async {
            tokenStore.save(Self.spentToken)
            let client = await makeClient(tokenStore: tokenStore)
            StubURLProtocol.stubsByPath = [
                Self.mePath: .init(statusCode: Self.httpUnauthorized, body: "{}"),
                Self.refreshPath: .init(statusCode: Self.httpUnauthorized, body: Self.rejectedBody)
            ]
            defer { resetStubs() }

            #expect(await failure(of: client) == String(describing: APIError.unauthorized))

            #expect(refreshFailures.value == 1)
        }

        @Test func successfulRefreshSavesAndRetriesWithTheNewToken() async throws {
            tokenStore.save(Self.spentToken)
            let client = await makeClient(tokenStore: tokenStore)
            StubURLProtocol.stubsByPath = [
                Self.mePath: .init(statusCode: Self.httpUnauthorized, body: "{}"),
                Self.refreshPath: .init(statusCode: Self.httpOK, body: Self.refreshBody)
            ]
            defer { resetStubs() }

            #expect(await failure(of: client) == String(describing: APIError.unauthorized))

            let retry = try #require(StubURLProtocol.requests.last)
            #expect(tokenStore.get() == Self.refreshedToken)
            #expect(retry.value(forHTTPHeaderField: "Authorization") == "Bearer \(Self.refreshedToken)")
            #expect(refreshFailures.value == 0)
        }

        @Test func tokenAlreadyRefreshedByAnotherRequestIsNotRefreshedAgain() async throws {
            let store = SequenceTokenStore([Self.spentToken, Self.refreshedToken])
            let client = await makeClient(tokenStore: store)
            StubURLProtocol.stubsByPath = [
                Self.mePath: .init(statusCode: Self.httpUnauthorized, body: "{}"),
                Self.refreshPath: .init(statusCode: Self.httpOK, body: Self.refreshBody)
            ]
            defer { resetStubs() }

            #expect(await failure(of: client) == String(describing: APIError.unauthorized))

            let retry = try #require(StubURLProtocol.requests.last)
            #expect(refreshRequests.isEmpty)
            #expect(retry.value(forHTTPHeaderField: "Authorization") == "Bearer \(Self.refreshedToken)")
        }
    }
}
