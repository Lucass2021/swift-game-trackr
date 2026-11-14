import Testing
@testable import GameTrackr

@MainActor
struct AuthStoreTests {
    private nonisolated static let token = "stored.token.value"
    private nonisolated static let rejectedMessage = "The token has been blacklisted"

    private let tokenStore = FakeTokenStore()
    private let repository = FakeAuthRepository()

    private func signedInStore() -> AuthStore {
        tokenStore.save(Self.token)
        return AuthStore(tokenStore: tokenStore, repository: repository)
    }

    @Test func aSessionCheckThatFailsWithoutA401KeepsTheSession() async {
        let authStore = signedInStore()
        await repository.setValidateFailure(APIError.serverError)

        await authStore.validate()

        #expect(authStore.isAuthenticated)
        #expect(tokenStore.get() == Self.token)
    }

    @Test func aSessionCheckRejectedWithA401EndsTheSession() async {
        let authStore = signedInStore()
        await repository.setValidateFailure(APIError.forbidden(Self.rejectedMessage))

        await authStore.validate()

        #expect(!authStore.isAuthenticated)
        #expect(tokenStore.get() == nil)
    }

    @Test func aSessionCheckAnsweredWithAPlain401EndsTheSession() async {
        let authStore = signedInStore()
        await repository.setValidateFailure(APIError.unauthorized)

        await authStore.validate()

        #expect(!authStore.isAuthenticated)
        #expect(tokenStore.get() == nil)
    }
}
