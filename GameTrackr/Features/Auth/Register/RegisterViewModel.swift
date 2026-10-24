import Foundation

@MainActor
@Observable
final class RegisterViewModel {
    static let nameMinLength = 3

    private(set) var name = ""
    private(set) var email = ""
    private(set) var password = ""
    private(set) var confirmPassword = ""
    private(set) var acceptedTerms = false
    private(set) var isSubmitted = false
    private(set) var isLoading = false
    private(set) var isRegistered = false
    var showSuccess = false
    var toastMessage: String?
    private var registeredUser: User?

    private let repository: AuthRepository
    private let googleAuth: GoogleAuth

    init(repository: AuthRepository = RemoteAuthRepository(), googleAuth: GoogleAuth? = nil) {
        self.repository = repository
        self.googleAuth = googleAuth ?? GoogleAuthService.shared
    }

    var nameError: String? {
        isSubmitted ? Self.nameError(for: name) : nil
    }

    var emailError: String? {
        isSubmitted ? AuthValidation.emailError(email) : nil
    }

    var passwordError: String? {
        isSubmitted ? AuthValidation.passwordError(password) : nil
    }

    var confirmPasswordError: String? {
        isSubmitted ? AuthValidation.confirmPasswordError(password: password, confirmation: confirmPassword) : nil
    }

    var termsError: String? {
        isSubmitted ? Self.termsError(for: acceptedTerms) : nil
    }

    var canSubmit: Bool {
        Self.nameError(for: name) == nil
            && AuthValidation.emailError(email) == nil
            && AuthValidation.passwordError(password) == nil
            && AuthValidation.confirmPasswordError(password: password, confirmation: confirmPassword) == nil
            && Self.termsError(for: acceptedTerms) == nil
    }

    func onNameChange(_ value: String) {
        name = value
    }

    func onEmailChange(_ value: String) {
        email = value
    }

    func onPasswordChange(_ value: String) {
        password = value
    }

    func onConfirmPasswordChange(_ value: String) {
        confirmPassword = value
    }

    func onToggleTerms() {
        acceptedTerms.toggle()
    }

    func submit() async {
        guard !isLoading, !isRegistered else { return }
        isSubmitted = true
        guard canSubmit else { return }

        isLoading = true
        toastMessage = nil
        defer { isLoading = false }

        do {
            registeredUser = try await repository.register(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password,
                passwordConfirmation: confirmPassword
            )
            isRegistered = true
            showSuccess = true
        } catch {
            toastMessage = error.userMessage()
        }
    }

    func completeRegistration(authStore: AuthStore) {
        guard let registeredUser else { return }
        authStore.authenticate(user: registeredUser)
    }

    func signUpWithGoogle(authStore: AuthStore) async {
        guard !isLoading, !isRegistered else { return }
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

    private static func nameError(for name: String) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return ValidationMessage.nameRequired }
        if trimmed.count < nameMinLength { return ValidationMessage.nameTooShort }
        return nil
    }

    private static func termsError(for accepted: Bool) -> String? {
        accepted ? nil : ValidationMessage.termsRequired
    }
}
