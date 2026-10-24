import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct VerifyResetCodeViewModelTests {
    private nonisolated static let email = "player@gametrackr.com"

    private let repository = FakeAuthRepository()

    private func viewModel(
        repository: FakeAuthRepository? = nil,
        tick: Duration = .seconds(60)
    ) -> VerifyResetCodeViewModel {
        VerifyResetCodeViewModel(email: Self.email, repository: repository ?? self.repository, tick: tick)
    }

    private func waitUntilResendIsAvailable(_ viewModel: VerifyResetCodeViewModel) async {
        for _ in 0 ..< 2000 where !viewModel.canResend {
            try? await Task.sleep(for: .milliseconds(1))
        }
    }

    @Test func theViewModelRunsTheCountdownAndUnlocksResend() async {
        let viewModel = viewModel(tick: .milliseconds(1))
        #expect(viewModel.resendSeconds == 30)

        await waitUntilResendIsAvailable(viewModel)

        #expect(viewModel.canResend)
    }

    @Test func resendIsIgnoredDuringTheCountdown() async {
        let viewModel = viewModel()

        await viewModel.resend()

        #expect(await repository.forgotPasswordCount == 0)
        #expect(!viewModel.canResend)
    }

    @Test func resendSendsANewCodeAndRestartsTheCountdown() async {
        let viewModel = viewModel(tick: .milliseconds(1))
        await waitUntilResendIsAvailable(viewModel)

        await viewModel.resend()

        #expect(await repository.forgotPasswordCount == 1)
        #expect(await repository.lastEmail == Self.email)
        #expect(!viewModel.canResend)
    }

    @Test func resendFailureShowsAToastAndLetsTheUserRetry() async {
        let viewModel = viewModel(tick: .milliseconds(1))
        await waitUntilResendIsAvailable(viewModel)
        await repository.setFailure(APIError.networkFailure)

        await viewModel.resend()

        #expect(viewModel.toastMessage == APIError.networkFailure.errorDescription)
        #expect(viewModel.canResend)
    }

    @Test func typingTheLastDigitVerifiesTheDigitsOnlyCodeOnce() async {
        let viewModel = viewModel()

        viewModel.onCodeChange("12a3")
        #expect(viewModel.code == "123")
        viewModel.onCodeChange("1234567")
        await viewModel.verifyTask?.value

        #expect(viewModel.code == "123456")
        #expect(await repository.verifyCount == 1)
        #expect(await repository.lastCode == "123456")
        #expect(viewModel.verifiedCode == "123456")
    }

    @Test func theSameCodeIsNotSubmittedAgain() async {
        await repository.setFailure(APIError.badRequest("Invalid code"))
        let viewModel = viewModel()
        viewModel.onCodeChange("123456")
        await viewModel.verifyTask?.value

        viewModel.onCodeChange("1234567")
        await viewModel.verifyTask?.value

        #expect(await repository.verifyCount == 1)
    }

    @Test func nonASCIIDigitsAreIgnored() {
        let viewModel = viewModel()

        viewModel.onCodeChange("\u{0661}\u{0662}\u{0663}456")

        #expect(viewModel.code == "456")
    }

    @Test func confirmingAnIncompleteCodeShowsTheLengthError() async {
        let viewModel = viewModel()
        #expect(viewModel.codeError == nil)

        await viewModel.submit()
        #expect(viewModel.codeError == "Code is required")

        viewModel.onCodeChange("123")
        #expect(viewModel.codeError == "Enter the 6-digit code")
        #expect(await repository.verifyCount == 0)
    }

    @Test func invalidCodeShowsAToastAndKeepsTheScreen() async {
        await repository.setFailure(APIError.badRequest("Invalid code"))
        let viewModel = viewModel()

        viewModel.onCodeChange("123456")
        await viewModel.verifyTask?.value

        #expect(viewModel.toastMessage == "Invalid code")
        #expect(viewModel.verifiedCode == nil)
        #expect(!viewModel.isLoading)
    }

    @Test func doubleConfirmSendsASingleVerifyRequest() async {
        let slowRepository = FakeAuthRepository(latency: .milliseconds(50))
        let viewModel = viewModel(repository: slowRepository)

        viewModel.onCodeChange("123456")
        await viewModel.submit()
        await viewModel.verifyTask?.value

        #expect(await slowRepository.verifyCount == 1)
    }
}
