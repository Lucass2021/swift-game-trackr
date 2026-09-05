import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct LoginViewModelTests {
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

    @Test func hidesFieldErrorsUntilTheFirstSubmit() {
        let viewModel = LoginViewModel(service: FakeAuthService(), googleAuth: FakeGoogleAuth())

        #expect(viewModel.emailError == nil)
        #expect(viewModel.passwordError == nil)
    }

    @Test func reportsFieldErrorsAfterSubmittingAnEmptyForm() async {
        let storage = InMemoryTokenStorage()
        let viewModel = LoginViewModel(service: FakeAuthService(), googleAuth: FakeGoogleAuth())

        await viewModel.signIn(authStore: makeStore(storage: storage))

        #expect(viewModel.emailError == ValidationMessage.emailRequired)
        #expect(viewModel.passwordError == ValidationMessage.passwordRequired)
        #expect(storage.get() == nil)
    }

    @Test func rejectsAPasswordShorterThanSixCharacters() async {
        let viewModel = LoginViewModel(service: FakeAuthService(), googleAuth: FakeGoogleAuth())
        viewModel.email = "lucas@example.com"
        viewModel.password = "12345"

        await viewModel.signIn(authStore: makeStore(storage: InMemoryTokenStorage()))

        #expect(viewModel.passwordError == ValidationMessage.passwordTooShort)
    }

    @Test func storesTheTokenOnASuccessfulSignIn() async {
        let storage = InMemoryTokenStorage()
        let store = makeStore(storage: storage)
        let service = FakeAuthService(response: TestData.authResponse(token: "jwt-token"))
        let viewModel = LoginViewModel(service: service, googleAuth: FakeGoogleAuth())
        viewModel.email = "lucas@example.com"
        viewModel.password = "secret123"

        await viewModel.signIn(authStore: store)

        #expect(store.isAuthenticated)
        #expect(store.currentUser?.name == "Lucas")
        #expect(storage.get() == "jwt-token")
        #expect(viewModel.errorMessage == nil)
    }

    @Test func surfacesTheServerMessageWhenSignInFails() async {
        let service = FakeAuthService(failure: .unauthorized)
        let viewModel = LoginViewModel(service: service, googleAuth: FakeGoogleAuth())
        viewModel.email = "lucas@example.com"
        viewModel.password = "wrongpass"

        await viewModel.signIn(authStore: makeStore(storage: InMemoryTokenStorage()))

        #expect(viewModel.errorMessage != nil)
    }

    @Test func staysSilentWhenGoogleSignInIsCancelled() async {
        let google = FakeGoogleAuth()
        google.failure = GoogleAuthError.cancelled
        let viewModel = LoginViewModel(service: FakeAuthService(), googleAuth: google)

        await viewModel.signInWithGoogle(authStore: makeStore(storage: InMemoryTokenStorage()))

        #expect(google.signInCount == 1)
        #expect(viewModel.errorMessage == nil)
    }
}
