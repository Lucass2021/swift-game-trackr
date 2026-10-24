import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct ResetPasswordViewModelTests {
    private nonisolated static let email = "player@gametrackr.com"
    private nonisolated static let code = "123456"
    private nonisolated static let password = "secret123"

    private let repository = FakeAuthRepository()
    private let authStore = AuthStore(tokenStore: FakeTokenStore())

    private func viewModel(
        repository: FakeAuthRepository? = nil,
        password: String = Self.password,
        confirmPassword: String = Self.password
    ) -> ResetPasswordViewModel {
        let viewModel = ResetPasswordViewModel(
            email: Self.email,
            code: Self.code,
            repository: repository ?? self.repository
        )
        viewModel.onPasswordChange(password)
        viewModel.onConfirmPasswordChange(confirmPassword)
        return viewModel
    }

    @Test func errorsShowOnlyAfterTheFirstSubmit() async {
        let viewModel = viewModel(password: "", confirmPassword: "x")
        #expect(viewModel.passwordError == nil)

        await viewModel.submit()

        #expect(viewModel.passwordError == "Password is required")
        #expect(viewModel.confirmPasswordError == "Passwords do not match")
        #expect(await repository.resetCount == 0)
    }

    @Test func shortPasswordIsRejected() async {
        let viewModel = viewModel(password: "abc", confirmPassword: "abc")

        await viewModel.submit()

        #expect(viewModel.passwordError == "At least 6 characters")
        #expect(await repository.resetCount == 0)
    }

    @Test func submitSendsTheEmailCodeAndNewPasswordAndShowsSuccess() async {
        let viewModel = viewModel()

        await viewModel.submit()

        #expect(await repository.lastEmail == Self.email)
        #expect(await repository.lastCode == Self.code)
        #expect(await repository.lastPassword == Self.password)
        #expect(viewModel.isReset)
        #expect(viewModel.showSuccess)
    }

    @Test func resetFailureShowsAToastAndKeepsTheForm() async {
        await repository.setFailure(APIError.badRequest("Invalid code"))
        let viewModel = viewModel()

        await viewModel.submit()

        #expect(viewModel.toastMessage == "Invalid code")
        #expect(!viewModel.isReset)
        #expect(viewModel.password == Self.password)
    }

    @Test func doubleSubmitAndSubmitAfterSuccessSendASingleRequest() async {
        let slowRepository = FakeAuthRepository(latency: .milliseconds(50))
        let viewModel = viewModel(repository: slowRepository)

        async let first: Void = viewModel.submit()
        async let second: Void = viewModel.submit()
        _ = await (first, second)
        await viewModel.submit()

        #expect(await slowRepository.resetCount == 1)
    }

    @Test func signInAfterResetLogsInWithTheNewPasswordOnce() async {
        let slowRepository = FakeAuthRepository(latency: .milliseconds(50))
        let viewModel = viewModel(repository: slowRepository)
        await viewModel.submit()

        async let button: Void = viewModel.signInAfterReset(authStore: authStore)
        async let redirect: Void = viewModel.signInAfterReset(authStore: authStore)
        _ = await (button, redirect)

        #expect(await slowRepository.loginCount == 1)
        #expect(await slowRepository.lastLoginPassword == Self.password)
        #expect(authStore.isAuthenticated)
    }

    @Test func signInFailureAfterResetReturnsToLogin() async {
        let viewModel = viewModel()
        await viewModel.submit()
        authStore.isResetFlowActive = true
        await repository.setFailure(APIError.unauthorized)

        await viewModel.signInAfterReset(authStore: authStore)

        #expect(!authStore.isResetFlowActive)
        #expect(!authStore.isAuthenticated)
    }
}
