import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct AuthStoreTests {
    private func makeStore(storage: TokenStorage) -> AuthStore {
        AuthStore(
            client: APIClient(
                session: StubURLProtocol.session,
                tokenStorage: storage,
                baseURL: "https://api.test"
            ),
            tokenStorage: storage
        )
    }

    @Test func startsAuthenticatedWhenTheInjectedStorageHoldsAToken() {
        let store = makeStore(storage: InMemoryTokenStorage(token: "jwt-token"))

        #expect(store.state == .authenticated)
        #expect(store.isInApp)
    }

    @Test func startsUnauthenticatedWhenTheStorageIsEmpty() {
        let store = makeStore(storage: InMemoryTokenStorage())

        #expect(store.state == .unauthenticated)
        #expect(!store.isInApp)
    }

    @Test func guestIsInTheAppShellButNotAuthenticated() {
        let store = makeStore(storage: InMemoryTokenStorage())

        store.continueAsGuest()

        #expect(store.isGuest)
        #expect(store.isInApp)
        #expect(!store.isAuthenticated)
    }

    @Test func logoutClearsTheTokenFromStorage() {
        let storage = InMemoryTokenStorage()
        let store = makeStore(storage: storage)

        store.authenticate(token: "jwt-token", user: TestData.user())
        #expect(storage.get() == "jwt-token")

        store.logout()

        #expect(storage.get() == nil)
        #expect(store.currentUser == nil)
        #expect(store.state == .unauthenticated)
    }
}
