import SwiftUI

@MainActor
@Observable
class LoginViewModel {
    var email = ""
    var password = ""
    var isLoading = false
    var errorMessage: String?
    private var submitted = false

    private let repository: AuthRepository

    init(repository: AuthRepository = RemoteAuthRepository()) {
        self.repository = repository
    }

    var emailError: String? {
        guard submitted else { return nil }
        if email.trimmingCharacters(in: .whitespaces).isEmpty { return ValidationMessage.emailRequired }
        if !email.contains("@") || !email.contains(".") { return ValidationMessage.emailInvalid }
        return nil
    }

    var passwordError: String? {
        guard submitted else { return nil }
        if password.isEmpty { return ValidationMessage.passwordRequired }
        if password.count < 6 { return ValidationMessage.passwordTooShort }
        return nil
    }

    func signIn(authStore: AuthStore) async {
        submitted = true
        guard emailError == nil, passwordError == nil else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let user = try await repository.login(email: email, password: password)
            authStore.authenticate(user: user)
        } catch {
            errorMessage = error.userMessage()
        }
    }

    func signInWithGoogle(authStore: AuthStore) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let token = try await GoogleAuthService.shared.signIn()
            let user = try await repository.signInWithGoogle(token: token)
            authStore.authenticate(user: user)
        } catch GoogleAuthError.cancelled {
        } catch {
            errorMessage = error.userMessage()
        }
    }

    func clear() {
        email = ""
        password = ""
        errorMessage = nil
        submitted = false
    }
}
