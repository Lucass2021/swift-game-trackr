import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct ChangePasswordViewModelTests {
    private static let current = "old-secret"
    private static let new = "new-secret"

    private let repository = FakePasswordRepository(latency: .zero)

    private func viewModel(
        current: String = Self.current,
        new: String = Self.new,
        confirm: String = Self.new
    ) -> ChangePasswordViewModel {
        let viewModel = ChangePasswordViewModel(repository: repository)
        viewModel.onCurrentPasswordChange(current)
        viewModel.onNewPasswordChange(new)
        viewModel.onConfirmPasswordChange(confirm)
        return viewModel
    }

    @Test func errorsShowOnlyAfterTheFirstSave() async {
        let viewModel = viewModel(current: "", new: "", confirm: "")
        #expect(viewModel.currentPasswordError == nil)

        await viewModel.save()

        #expect(viewModel.currentPasswordError == "Current password is required")
        #expect(viewModel.newPasswordError == "New password is required")
        #expect(viewModel.confirmPasswordError == "Confirm your new password")
        #expect(await repository.changeCount == 0)
    }

    @Test func shortAndMismatchedPasswordsAreRejected() async {
        let viewModel = viewModel(new: "abc", confirm: "abd")

        await viewModel.save()

        #expect(viewModel.newPasswordError == "At least 6 characters")
        #expect(viewModel.confirmPasswordError == "Passwords do not match")
        #expect(await repository.changeCount == 0)
    }

    @Test func saveSendsTheNewPasswordAndMarksItAsChanged() async {
        let viewModel = viewModel()

        await viewModel.save()

        #expect(await repository.changeCount == 1)
        #expect(await repository.lastCurrentPassword == Self.current)
        #expect(await repository.lastNewPassword == Self.new)
        #expect(viewModel.isChanged)
        #expect(!viewModel.isSaving)
    }

    @Test func aSaveFailureShowsAToastAndKeepsTheForm() async {
        await repository.setFailure(APIError.networkFailure)
        let viewModel = viewModel()

        await viewModel.save()

        #expect(viewModel.toastMessage == APIError.networkFailure.userMessage())
        #expect(!viewModel.isChanged)
        #expect(viewModel.newPassword == Self.new)
    }

    @Test func aSecondTapWhileSavingAndASaveAfterSuccessSendNoRequest() async {
        let slowRepository = FakePasswordRepository(latency: .milliseconds(50))
        let viewModel = ChangePasswordViewModel(repository: slowRepository)
        viewModel.onCurrentPasswordChange(Self.current)
        viewModel.onNewPasswordChange(Self.new)
        viewModel.onConfirmPasswordChange(Self.new)

        async let first: Void = viewModel.save()
        async let second: Void = viewModel.save()
        _ = await (first, second)
        await viewModel.save()

        #expect(await slowRepository.changeCount == 1)
    }
}
