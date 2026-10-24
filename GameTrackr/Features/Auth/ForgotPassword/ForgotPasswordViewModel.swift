import SwiftUI

@MainActor
@Observable
class ForgotPasswordViewModel {
    var email = ""
    var isLoading = false
    var errorMessage: String?
    var showVerifyCode = false
    private var submitted = false

    private let repository: AuthRepository

    init(repository: AuthRepository = RemoteAuthRepository()) {
        self.repository = repository
    }

    var emailError: String? {
        submitted ? AuthValidation.emailError(email) : nil
    }

    func sendCode() async {
        submitted = true
        guard emailError == nil else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await repository.forgotPassword(email: email)
            showVerifyCode = true
        } catch {
            errorMessage = error.userMessage()
        }
    }
}
