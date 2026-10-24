import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct ForgotPasswordViewModelTests {
    private nonisolated static let email = "player@gametrackr.com"

    private let repository = FakeAuthRepository()

    private func viewModel(
        repository: FakeAuthRepository? = nil,
        email: String = Self.email
    ) -> ForgotPasswordViewModel {
        let viewModel = ForgotPasswordViewModel(repository: repository ?? self.repository)
        viewModel.onEmailChange(email)
        return viewModel
    }

    @Test func errorsShowOnlyAfterTheFirstSubmit() async {
        let viewModel = viewModel(email: "")
        #expect(viewModel.emailError == nil)

        await viewModel.submit()

        #expect(viewModel.emailError == "Email is required")
        #expect(await repository.forgotPasswordCount == 0)
    }

    @Test func submitSendsTheTrimmedEmailAndHandsItToTheNextStep() async {
        let viewModel = viewModel(email: "  \(Self.email)  ")

        await viewModel.submit()

        #expect(await repository.lastEmail == Self.email)
        #expect(viewModel.sentToEmail == Self.email)
        #expect(!viewModel.isLoading)
    }

    @Test func sendFailureShowsAToastAndStaysOnTheScreen() async {
        await repository.setFailure(APIError.notFound)
        let viewModel = viewModel()

        await viewModel.submit()

        #expect(viewModel.toastMessage == APIError.notFound.errorDescription)
        #expect(viewModel.sentToEmail == nil)
        #expect(viewModel.email == Self.email)
    }

    @Test func doubleSubmitSendsASingleCodeRequest() async {
        let slowRepository = FakeAuthRepository(latency: .milliseconds(50))
        let viewModel = viewModel(repository: slowRepository)

        async let first: Void = viewModel.submit()
        async let second: Void = viewModel.submit()
        _ = await (first, second)

        #expect(await slowRepository.forgotPasswordCount == 1)
    }

    @Test func aNewSubmitAfterComingBackSendsANewCode() async {
        let viewModel = viewModel()
        await viewModel.submit()
        viewModel.sentToEmail = nil

        await viewModel.submit()

        #expect(await repository.forgotPasswordCount == 2)
    }
}
