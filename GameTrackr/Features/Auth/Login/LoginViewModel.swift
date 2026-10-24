import Foundation

@MainActor
@Observable
final class LoginViewModel {
    private(set) var email = ""
    private(set) var password = ""
    private(set) var isSubmitted = false
    private(set) var isLoading = false
    var toastMessage: String?

    private let repository: AuthRepository
    private let googleAuth: GoogleAuth

    init(repository: AuthRepository = RemoteAuthRepository(), googleAuth: GoogleAuth? = nil) {
        self.repository = repository
        self.googleAuth = googleAuth ?? GoogleAuthService.shared
    }

    var emailError: String? {
        isSubmitted ? AuthValidation.emailError(email) : nil
    }

    var passwordError: String? {
        isSubmitted ? AuthValidation.passwordError(password) : nil
    }

    var canSubmit: Bool {
        AuthValidation.emailError(email) == nil && AuthValidation.passwordError(password) == nil
    }

    func onEmailChange(_ value: String) {
        email = value
    }

    func onPasswordChange(_ value: String) {
        password = value
    }

    func submit(authStore: AuthStore) async {
        guard !isLoading else { return }
        isSubmitted = true
        guard canSubmit else { return }

        isLoading = true
        toastMessage = nil
        defer { isLoading = false }

        do {
            let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
            let user = try await repository.login(email: trimmedEmail, password: password)
            authStore.authenticate(user: user)
        } catch {
            toastMessage = error.userMessage()
        }
    }

    func signInWithGoogle(authStore: AuthStore) async {
        guard !isLoading else { return }
        isLoading = true
        toastMessage = nil
        defer { isLoading = false }

        do {
            let token = try await googleAuth.signIn()
            let user = try await repository.signInWithGoogle(token: token)
            authStore.authenticate(user: user)
        } catch GoogleAuthError.cancelled {
        } catch {
            toastMessage = error.userMessage()
        }
    }
}
