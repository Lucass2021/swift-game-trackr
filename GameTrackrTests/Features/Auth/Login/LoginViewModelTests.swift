import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct LoginViewModelTests {
    private nonisolated static let email = "player@gametrackr.com"
    private nonisolated static let password = "secret123"

    private let repository = FakeAuthRepository()
    private let googleAuth = FakeGoogleAuth()
    private let authStore = AuthStore(tokenStore: FakeTokenStore())

    private func viewModel(
        repository: FakeAuthRepository? = nil,
        email: String = Self.email,
        password: String = Self.password
    ) -> LoginViewModel {
        let viewModel = LoginViewModel(repository: repository ?? self.repository, googleAuth: googleAuth)
        viewModel.onEmailChange(email)
        viewModel.onPasswordChange(password)
        return viewModel
    }

    @Test func errorsShowOnlyAfterTheFirstSubmit() async {
        let viewModel = viewModel(email: "", password: "")
        #expect(viewModel.emailError == nil)

        await viewModel.submit(authStore: authStore)

        #expect(viewModel.emailError == "Email is required")
        #expect(viewModel.passwordError == "Password is required")
        #expect(await repository.loginCount == 0)
    }

    @Test func invalidEmailAndShortPasswordAreRejected() async {
        let viewModel = viewModel(email: "player", password: "abc")

        await viewModel.submit(authStore: authStore)

        #expect(viewModel.emailError == "Enter a valid email")
        #expect(viewModel.passwordError == "At least 6 characters")
        #expect(await repository.loginCount == 0)
    }

    @Test func fixingAFieldAfterSubmitClearsItsError() async {
        let viewModel = viewModel(password: "")
        await viewModel.submit(authStore: authStore)

        viewModel.onPasswordChange(Self.password)

        #expect(viewModel.passwordError == nil)
    }

    @Test func submitSendsTheTrimmedEmailAndSignsIn() async {
        let viewModel = viewModel(email: "  \(Self.email)  ")

        await viewModel.submit(authStore: authStore)

        #expect(await repository.lastEmail == Self.email)
        #expect(await repository.lastPassword == Self.password)
        #expect(authStore.isAuthenticated)
        #expect(!viewModel.isLoading)
        #expect(viewModel.toastMessage == nil)
    }

    @Test func loginFailureShowsAToastAndKeepsTheFields() async {
        await repository.setFailure(APIError.unauthorized)
        let viewModel = viewModel()

        await viewModel.submit(authStore: authStore)

        #expect(viewModel.toastMessage == APIError.unauthorized.errorDescription)
        #expect(viewModel.email == Self.email)
        #expect(viewModel.password == Self.password)
        #expect(!authStore.isAuthenticated)
        #expect(!viewModel.isLoading)
    }

    @Test func doubleSubmitSendsASingleLoginRequest() async {
        let slowRepository = FakeAuthRepository(latency: .milliseconds(50))
        let viewModel = viewModel(repository: slowRepository)

        async let first: Void = viewModel.submit(authStore: authStore)
        async let second: Void = viewModel.submit(authStore: authStore)
        _ = await (first, second)

        #expect(await slowRepository.loginCount == 1)
    }

    @Test func googleIsIgnoredWhileALoginIsInFlight() async {
        let slowRepository = FakeAuthRepository(latency: .milliseconds(50))
        let viewModel = viewModel(repository: slowRepository)

        let login = Task { await viewModel.submit(authStore: authStore) }
        for _ in 0 ..< 1000 where !viewModel.isLoading {
            await Task.yield()
        }
        #expect(viewModel.isLoading)

        await viewModel.signInWithGoogle(authStore: authStore)
        await login.value

        #expect(googleAuth.signInCount == 0)
        #expect(await slowRepository.loginCount == 1)
    }

    @Test func signInWithGoogleSendsTheTokenAndSignsIn() async {
        let viewModel = viewModel()

        await viewModel.signInWithGoogle(authStore: authStore)

        #expect(googleAuth.signInCount == 1)
        #expect(await repository.lastGoogleToken == "google-token")
        #expect(authStore.isAuthenticated)
    }

    @Test func cancelledGoogleSignInShowsNothing() async {
        googleAuth.result = .failure(GoogleAuthError.cancelled)
        let viewModel = viewModel()

        await viewModel.signInWithGoogle(authStore: authStore)

        #expect(viewModel.toastMessage == nil)
        #expect(!authStore.isAuthenticated)
        #expect(!viewModel.isLoading)
    }

    @Test func googleSignInFailureShowsAToast() async {
        await repository.setFailure(APIError.networkFailure)
        let viewModel = viewModel()

        await viewModel.signInWithGoogle(authStore: authStore)

        #expect(viewModel.toastMessage == APIError.networkFailure.errorDescription)
        #expect(!authStore.isAuthenticated)
    }
}
