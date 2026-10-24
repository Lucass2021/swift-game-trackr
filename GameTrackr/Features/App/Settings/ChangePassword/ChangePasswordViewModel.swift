import Foundation

@MainActor
@Observable
final class ChangePasswordViewModel {
    private(set) var currentPassword = ""
    private(set) var newPassword = ""
    private(set) var confirmPassword = ""
    private(set) var isSubmitted = false
    private(set) var isSaving = false
    private(set) var isChanged = false
    var toastMessage: String?

    private let repository: PasswordRepository

    init(repository: PasswordRepository) {
        self.repository = repository
    }

    var currentPasswordError: String? {
        isSubmitted ? Self.currentPasswordError(for: currentPassword) : nil
    }

    var newPasswordError: String? {
        isSubmitted ? Self.newPasswordError(for: newPassword, currentPassword: currentPassword) : nil
    }

    var confirmPasswordError: String? {
        isSubmitted ? Self.confirmPasswordError(for: confirmPassword, password: newPassword) : nil
    }

    var canSave: Bool {
        Self.currentPasswordError(for: currentPassword) == nil
            && Self.newPasswordError(for: newPassword, currentPassword: currentPassword) == nil
            && Self.confirmPasswordError(for: confirmPassword, password: newPassword) == nil
    }

    func onCurrentPasswordChange(_ value: String) {
        currentPassword = value
    }

    func onNewPasswordChange(_ value: String) {
        newPassword = value
    }

    func onConfirmPasswordChange(_ value: String) {
        confirmPassword = value
    }

    func save() async {
        guard !isSaving, !isChanged else { return }
        isSubmitted = true
        guard canSave else { return }

        isSaving = true
        toastMessage = nil
        defer { isSaving = false }

        do {
            try await repository.changePassword(currentPassword: currentPassword, newPassword: newPassword)
            isChanged = true
        } catch {
            toastMessage = error.userMessage()
        }
    }

    private static func currentPasswordError(for password: String) -> String? {
        password.isEmpty ? "Current password is required" : nil
    }

    private static func newPasswordError(for password: String, currentPassword: String) -> String? {
        let minLength = AuthValidation.passwordMinLength
        if password.isEmpty { return "New password is required" }
        if password.count < minLength { return ValidationMessage.passwordTooShort(minLength) }
        if password == currentPassword { return "New password must be different from the current one" }
        return nil
    }

    private static func confirmPasswordError(for confirmation: String, password: String) -> String? {
        if confirmation.isEmpty { return "Confirm your new password" }
        if confirmation != password { return "Passwords do not match" }
        return nil
    }
}
