import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct RegisterViewModelTests {
    private func makeViewModel() -> RegisterViewModel {
        RegisterViewModel(service: FakeAuthService(), googleAuth: FakeGoogleAuth())
    }

    private func makeAuthStore() -> AuthStore {
        let storage = InMemoryTokenStorage()
        return AuthStore(
            client: APIClient(session: StubURLProtocol.session, tokenStorage: storage, baseURL: "https://api.test"),
            tokenStorage: storage
        )
    }

    @Test func hidesEveryFieldErrorBeforeTheFirstSubmit() {
        let viewModel = makeViewModel()

        #expect(viewModel.nameError == nil)
        #expect(viewModel.emailError == nil)
        #expect(viewModel.passwordError == nil)
        #expect(viewModel.confirmPasswordError == nil)
        #expect(viewModel.termsError == nil)
    }

    @Test func showsEveryFieldErrorOnceAnEmptyFormIsSubmitted() async {
        let viewModel = makeViewModel()

        await viewModel.signUp(authStore: makeAuthStore())

        #expect(viewModel.nameError == ValidationMessage.nameRequired)
        #expect(viewModel.emailError == ValidationMessage.emailRequired)
        #expect(viewModel.passwordError == ValidationMessage.passwordRequired)
        #expect(viewModel.termsError == ValidationMessage.termsRequired)
    }

    @Test func rejectsANameThatIsOnlyWhitespaceOrTooShort() async {
        let viewModel = makeViewModel()
        viewModel.name = "   "
        await viewModel.signUp(authStore: makeAuthStore())
        #expect(viewModel.nameError == ValidationMessage.nameRequired)

        viewModel.name = "Lu"
        #expect(viewModel.nameError == ValidationMessage.nameTooShort)

        viewModel.name = "Lucas"
        #expect(viewModel.nameError == nil)
    }

    @Test func requiresBothAnAtSignAndADotInTheEmail() async {
        let viewModel = makeViewModel()
        viewModel.email = "lucas@example"
        await viewModel.signUp(authStore: makeAuthStore())

        #expect(viewModel.emailError == ValidationMessage.emailInvalid)

        viewModel.email = "lucas.example.com"
        #expect(viewModel.emailError == ValidationMessage.emailInvalid)

        viewModel.email = "lucas@example.com"
        #expect(viewModel.emailError == nil)
    }

    @Test func requiresSixCharactersAndAMatchingConfirmation() async {
        let viewModel = makeViewModel()
        viewModel.password = "12345"
        viewModel.confirmPassword = "54321"
        await viewModel.signUp(authStore: makeAuthStore())

        #expect(viewModel.passwordError == ValidationMessage.passwordTooShort)
        #expect(viewModel.confirmPasswordError == ValidationMessage.passwordsDoNotMatch)

        viewModel.password = "123456"
        viewModel.confirmPassword = "123456"
        #expect(viewModel.passwordError == nil)
        #expect(viewModel.confirmPasswordError == nil)
    }

    @Test func doesNotCallTheApiWhileTheFormIsInvalid() async {
        let service = FakeAuthService(response: TestData.authResponse())
        let viewModel = RegisterViewModel(service: service, googleAuth: FakeGoogleAuth())
        viewModel.name = "Lucas"

        await viewModel.signUp(authStore: makeAuthStore())

        #expect(!viewModel.showSuccess)
        #expect(!viewModel.isLoading)
    }

    @Test func hidesTheErrorsAgainAfterClear() async {
        let viewModel = makeViewModel()
        await viewModel.signUp(authStore: makeAuthStore())
        #expect(viewModel.nameError != nil)

        viewModel.clear()

        #expect(viewModel.nameError == nil)
        #expect(viewModel.name.isEmpty)
        #expect(!viewModel.acceptedTerms)
    }
}
