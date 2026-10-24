import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct RegisterViewModelTests {
    private nonisolated static let name = "Player One"
    private nonisolated static let email = "player@gametrackr.com"
    private nonisolated static let password = "secret123"

    private let repository = FakeAuthRepository()
    private let googleAuth = FakeGoogleAuth()
    private let authStore = AuthStore(tokenStore: FakeTokenStore())

    private func viewModel(
        repository: FakeAuthRepository? = nil,
        name: String = Self.name,
        email: String = Self.email,
        password: String = Self.password,
        confirmPassword: String = Self.password,
        acceptTerms: Bool = true
    ) -> RegisterViewModel {
        let viewModel = RegisterViewModel(repository: repository ?? self.repository, googleAuth: googleAuth)
        viewModel.onNameChange(name)
        viewModel.onEmailChange(email)
        viewModel.onPasswordChange(password)
        viewModel.onConfirmPasswordChange(confirmPassword)
        if acceptTerms { viewModel.onToggleTerms() }
        return viewModel
    }

    @Test func errorsShowOnlyAfterTheFirstSubmit() async {
        let viewModel = viewModel(name: "", email: "", password: "", confirmPassword: "", acceptTerms: false)
        #expect(viewModel.nameError == nil)

        await viewModel.submit()

        #expect(viewModel.nameError == "Full name is required")
        #expect(viewModel.emailError == "Email is required")
        #expect(viewModel.passwordError == "Password is required")
        #expect(viewModel.confirmPasswordError == nil)
        #expect(viewModel.termsError == "You must accept the terms to continue")
        #expect(await repository.registerCount == 0)
    }

    @Test func shortNameShortPasswordAndMismatchedConfirmationAreRejected() async {
        let viewModel = viewModel(name: " Al ", password: "abc", confirmPassword: "abd")

        await viewModel.submit()

        #expect(viewModel.nameError == "At least 3 characters")
        #expect(viewModel.passwordError == "At least 6 characters")
        #expect(viewModel.confirmPasswordError == "Passwords do not match")
        #expect(viewModel.termsError == nil)
        #expect(await repository.registerCount == 0)
    }

    @Test func acceptingTheTermsAfterSubmitClearsTheTermsError() async {
        let viewModel = viewModel(acceptTerms: false)
        await viewModel.submit()

        viewModel.onToggleTerms()

        #expect(viewModel.termsError == nil)
    }

    @Test func submitSendsTrimmedNameAndEmailAndShowsSuccess() async {
        let viewModel = viewModel(name: "  \(Self.name)  ", email: "  \(Self.email)  ")

        await viewModel.submit()

        #expect(await repository.lastName == Self.name)
        #expect(await repository.lastEmail == Self.email)
        #expect(await repository.lastPassword == Self.password)
        #expect(viewModel.isRegistered)
        #expect(viewModel.showSuccess)
        #expect(!authStore.isAuthenticated)

        viewModel.completeRegistration(authStore: authStore)
        #expect(authStore.isAuthenticated)
    }

    @Test func registerFailureShowsAToastAndKeepsTheForm() async {
        await repository.setFailure(APIError.validation("The email has already been taken."))
        let viewModel = viewModel()

        await viewModel.submit()

        #expect(viewModel.toastMessage == "The email has already been taken.")
        #expect(!viewModel.isRegistered)
        #expect(viewModel.name == Self.name)
    }

    @Test func doubleSubmitAndSubmitAfterSuccessSendASingleRequest() async {
        let slowRepository = FakeAuthRepository(latency: .milliseconds(50))
        let viewModel = viewModel(repository: slowRepository)

        async let first: Void = viewModel.submit()
        async let second: Void = viewModel.submit()
        _ = await (first, second)
        await viewModel.submit()
        await viewModel.signUpWithGoogle(authStore: authStore)

        #expect(await slowRepository.registerCount == 1)
        #expect(googleAuth.signInCount == 0)
    }

    @Test func googleIsIgnoredWhileRegistering() async {
        let slowRepository = FakeAuthRepository(latency: .milliseconds(50))
        let viewModel = viewModel(repository: slowRepository)

        let register = Task { await viewModel.submit() }
        for _ in 0 ..< 1000 where !viewModel.isLoading {
            await Task.yield()
        }
        #expect(viewModel.isLoading)

        await viewModel.signUpWithGoogle(authStore: authStore)
        await register.value

        #expect(googleAuth.signInCount == 0)
    }

    @Test func signUpWithGoogleSignsIn() async {
        let viewModel = viewModel()

        await viewModel.signUpWithGoogle(authStore: authStore)

        #expect(await repository.lastGoogleToken == "google-token")
        #expect(authStore.isAuthenticated)
    }

    @Test func cancelledGoogleSignUpShowsNothing() async {
        googleAuth.result = .failure(GoogleAuthError.cancelled)
        let viewModel = viewModel()

        await viewModel.signUpWithGoogle(authStore: authStore)

        #expect(viewModel.toastMessage == nil)
        #expect(!viewModel.isLoading)
    }
}
