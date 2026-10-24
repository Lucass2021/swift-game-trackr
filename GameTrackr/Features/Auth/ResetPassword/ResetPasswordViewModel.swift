import Foundation

@MainActor
@Observable
final class ResetPasswordViewModel {
    let email: String
    let code: String
    private(set) var password = ""
    private(set) var confirmPassword = ""
    private(set) var isSubmitted = false
    private(set) var isLoading = false
    private(set) var isReset = false
    var showSuccess = false
    var toastMessage: String?

    private let repository: AuthRepository

    init(email: String, code: String, repository: AuthRepository = RemoteAuthRepository()) {
        self.email = email
        self.code = code
        self.repository = repository
    }

    var passwordError: String? {
        isSubmitted ? AuthValidation.passwordError(password) : nil
    }

    var confirmPasswordError: String? {
        isSubmitted ? AuthValidation.confirmPasswordError(password: password, confirmation: confirmPassword) : nil
    }

    var canSubmit: Bool {
        AuthValidation.passwordError(password) == nil
            && AuthValidation.confirmPasswordError(password: password, confirmation: confirmPassword) == nil
    }

    func onPasswordChange(_ value: String) {
        password = value
    }

    func onConfirmPasswordChange(_ value: String) {
        confirmPassword = value
    }

    func submit() async {
        guard !isLoading, !isReset else { return }
        isSubmitted = true
        guard canSubmit else { return }

        isLoading = true
        toastMessage = nil
        defer { isLoading = false }

        do {
            try await repository.resetPassword(email: email, code: code, newPassword: password)
            isReset = true
            showSuccess = true
        } catch {
            toastMessage = error.userMessage()
        }
    }

    func signInAfterReset(authStore: AuthStore) async {
        guard isReset, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let user = try await repository.login(email: email, password: password)
            authStore.authenticate(user: user)
        } catch {
            authStore.isResetFlowActive = false
        }
    }
}
