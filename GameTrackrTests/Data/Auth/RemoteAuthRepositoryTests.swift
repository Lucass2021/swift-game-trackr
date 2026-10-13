import Testing
@testable import GameTrackr

extension RepositoryTests {
    @MainActor
    struct RemoteAuthRepositoryTests {
        private static let httpOK = 200
        private static let httpUnauthorized = 401
        private static let email = "player@gametrackr.dev"
        private static let password = "secret123"
        private static let token = "header.payload.signature"
        private static let invalidCredentialsBody = #"{"error":"Invalid credentials"}"#
        private static let loginSuccessBody = #"""
        {"token":"\#(token)","user":{"id":1,"name":"Player","email":"\#(email)"},"message":"Logged in successfully"}
        """#

        private let tokenStore = FakeTokenStore()
        private let repository: RemoteAuthRepository

        init() {
            let apiClient = APIClient(session: StubURLProtocol.makeSession(), tokenStore: tokenStore)
            repository = RemoteAuthRepository(apiClient: apiClient, tokenStore: tokenStore)
        }

        @Test func loginWithWrongPasswordFailsWithInvalidCredentials() async {
            StubURLProtocol.stub = .init(statusCode: Self.httpUnauthorized, body: Self.invalidCredentialsBody)

            do {
                _ = try await repository.login(email: Self.email, password: Self.password)
                Issue.record("Expected the login to fail")
            } catch APIError.unauthorized {
            } catch {
                Issue.record("Expected APIError.unauthorized, got \(error)")
            }
            #expect(tokenStore.get() == nil)
        }

        @Test func loginSuccessSavesTheTokenAndReturnsTheUser() async throws {
            StubURLProtocol.stub = .init(statusCode: Self.httpOK, body: Self.loginSuccessBody)

            let user = try await repository.login(email: Self.email, password: Self.password)

            #expect(user.email == Self.email)
            #expect(tokenStore.get() == Self.token)
        }
    }
}
