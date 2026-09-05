import Foundation
import Testing
@testable import GameTrackr

@Suite(.serialized)
struct APIClientTests {
    private func makeClient(storage: TokenStorage = InMemoryTokenStorage()) -> APIClient {
        StubURLProtocol.reset()
        return APIClient(
            session: StubURLProtocol.session,
            tokenStorage: storage,
            baseURL: "https://api.test"
        )
    }

    @Test func decodesAPublicFeedThroughTheInjectedSession() async throws {
        let client = makeClient()
        StubURLProtocol.enqueue(json: #"{"message":"ok","data":[{"id":1,"name":"Hades II"}]}"#)

        let response: GamesResponse = try await client.request(.newReleases(limit: 10))

        #expect(response.data.map(\.name) == ["Hades II"])
        #expect(StubURLProtocol.requestedPaths == ["/home/new-releases"])
        #expect(StubURLProtocol.sentAuthorizations == [nil])
    }

    @Test func decodesAGameWithNoCoverAndNoReleaseDate() async throws {
        let client = makeClient()
        StubURLProtocol.enqueue(json: #"{"data":[{"id":7,"name":"Obscure Indie"}]}"#)

        let response: GamesResponse = try await client.request(.newReleases(limit: 1))
        let game = try #require(response.data.first)

        #expect(game.cover == nil)
        #expect(game.firstReleaseDate == nil)
    }

    @Test func mapsA401CarryingAnErrorBodyToForbiddenWithoutRefreshing() async {
        let client = makeClient(storage: InMemoryTokenStorage(token: "stale-token"))
        StubURLProtocol.enqueue(status: 401, json: #"{"error":"Only the author can delete it."}"#)

        do {
            let _: MessageResponse = try await client.request(.deleteCommunity(id: 1))
            Issue.record("expected the request to fail")
        } catch let error as APIError {
            guard case let .forbidden(message) = error else {
                Issue.record("expected .forbidden, got \(error)")
                return
            }
            #expect(message == "Only the author can delete it.")
        } catch {
            Issue.record("expected an APIError, got \(error)")
        }

        #expect(StubURLProtocol.requestedPaths == ["/communities/1"])
    }

    @Test func refreshesAndReplaysOnAnUnauthenticated401() async throws {
        let storage = InMemoryTokenStorage(token: "stale-token")
        let client = makeClient(storage: storage)
        StubURLProtocol.enqueue(status: 401, json: #"{"message":"Unauthenticated."}"#)
        StubURLProtocol.enqueue(json: #"{"token":"fresh-token"}"#)
        StubURLProtocol.enqueue(json: #"{"message":"Community deleted"}"#)

        let response: MessageResponse = try await client.request(.deleteCommunity(id: 1))

        #expect(response.message == "Community deleted")
        #expect(StubURLProtocol.requestedPaths == ["/communities/1", "/auth/refresh", "/communities/1"])
        #expect(StubURLProtocol.sentAuthorizations.last == "Bearer fresh-token")
        #expect(storage.get() == "fresh-token")
    }

    @Test func surfacesTheFirstValidationMessageOn422() async {
        let client = makeClient()
        StubURLProtocol.enqueue(
            status: 422,
            json: #"{"message":"Invalid","errors":{"email":["The email has already been taken."]}}"#
        )

        do {
            let _: AuthResponse = try await client.request(.register)
            Issue.record("expected the request to fail")
        } catch let APIError.validation(message) {
            #expect(message == "The email has already been taken.")
        } catch {
            Issue.record("expected .validation, got \(error)")
        }
    }
}
