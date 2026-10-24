import Foundation

@MainActor
@Observable
final class ForgotPasswordViewModel {
    private(set) var email = ""
    private(set) var isSubmitted = false
    private(set) var isLoading = false
    var sentToEmail: String?
    var toastMessage: String?

    private let repository: AuthRepository

    init(repository: AuthRepository = RemoteAuthRepository()) {
        self.repository = repository
    }

    var emailError: String? {
        isSubmitted ? AuthValidation.emailError(email) : nil
    }

    var canSubmit: Bool {
        AuthValidation.emailError(email) == nil
    }

    func onEmailChange(_ value: String) {
        email = value
    }

    func submit() async {
        guard !isLoading else { return }
        isSubmitted = true
        guard canSubmit else { return }

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        isLoading = true
        toastMessage = nil
        defer { isLoading = false }

        do {
            try await repository.forgotPassword(email: trimmedEmail)
            sentToEmail = trimmedEmail
        } catch {
            toastMessage = error.userMessage()
        }
    }
}
