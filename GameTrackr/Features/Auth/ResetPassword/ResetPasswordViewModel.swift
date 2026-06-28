import SwiftUI

@MainActor
@Observable
class ResetPasswordViewModel {
    let resetToken: String
    var password = ""
    var confirmPassword = ""
    var isLoading = false
    var errorMessage: String?
    var showSuccess = false
    private var submitted = false

    private let service: AuthServicing

    init(resetToken: String, service: AuthServicing = AuthService.live) {
        self.resetToken = resetToken
        self.service = service
    }

    var passwordError: String? {
        guard submitted else { return nil }
        if password.isEmpty { return ValidationMessage.passwordRequired }
        if password.count < 6 { return ValidationMessage.passwordTooShort }
        return nil
    }

    var confirmPasswordError: String? {
        guard submitted else { return nil }
        if confirmPassword != password { return ValidationMessage.passwordsDoNotMatch }
        return nil
    }

    func resetPassword() async {
        submitted = true
        guard passwordError == nil, confirmPasswordError == nil else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await service.resetPassword(resetToken: resetToken, newPassword: password)
            showSuccess = true
        } catch {
            errorMessage = error.userMessage()
        }
    }
}
