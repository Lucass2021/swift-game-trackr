import SwiftUI

@MainActor
@Observable
class ResetPasswordViewModel {
    let email: String
    let code: String
    var password = ""
    var confirmPassword = ""
    var isLoading = false
    var errorMessage: String?
    var showSuccess = false
    private var submitted = false

    private let repository: AuthRepository

    init(email: String, code: String, repository: AuthRepository = RemoteAuthRepository()) {
        self.email = email
        self.code = code
        self.repository = repository
    }

    var passwordError: String? {
        submitted ? AuthValidation.passwordError(password) : nil
    }

    var confirmPasswordError: String? {
        submitted ? AuthValidation.confirmPasswordError(password: password, confirmation: confirmPassword) : nil
    }

    func resetPassword() async {
        submitted = true
        guard passwordError == nil, confirmPasswordError == nil else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await repository.resetPassword(email: email, code: code, newPassword: password)
            showSuccess = true
        } catch {
            errorMessage = error.userMessage()
        }
    }

    func signInAfterReset(authStore: AuthStore) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let user = try await repository.login(email: email, password: password)
            authStore.authenticate(user: user)
        } catch {
            errorMessage = error.userMessage()
        }
    }
}
