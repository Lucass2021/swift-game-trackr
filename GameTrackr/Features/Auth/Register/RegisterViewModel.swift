import SwiftUI

@MainActor
@Observable
class RegisterViewModel {
    var name = ""
    var email = ""
    var password = ""
    var confirmPassword = ""
    var acceptedTerms = false
    var isLoading = false
    var errorMessage: String?
    var showSuccess = false
    private var submitted = false
    private var pendingUser: User?

    private let repository: AuthRepository

    init(repository: AuthRepository = RemoteAuthRepository()) {
        self.repository = repository
    }

    var nameError: String? {
        guard submitted else { return nil }
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return ValidationMessage.nameRequired }
        if trimmed.count < 3 { return ValidationMessage.nameTooShort }
        return nil
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

    var confirmPasswordError: String? {
        guard submitted else { return nil }
        if confirmPassword != password { return ValidationMessage.passwordsDoNotMatch }
        return nil
    }

    var termsError: String? {
        guard submitted else { return nil }
        if !acceptedTerms { return ValidationMessage.termsRequired }
        return nil
    }

    func signUp(authStore _: AuthStore) async {
        submitted = true
        guard nameError == nil, emailError == nil, passwordError == nil, confirmPasswordError == nil,
              termsError == nil else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            pendingUser = try await repository.register(
                name: name,
                email: email,
                password: password,
                passwordConfirmation: confirmPassword
            )
            showSuccess = true
        } catch {
            errorMessage = error.userMessage()
        }
    }

    func completeRegistration(authStore: AuthStore) {
        guard let pendingUser else { return }
        authStore.authenticate(user: pendingUser)
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
        name = ""
        email = ""
        password = ""
        confirmPassword = ""
        acceptedTerms = false
        errorMessage = nil
        submitted = false
    }
}
