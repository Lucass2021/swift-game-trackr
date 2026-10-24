import Foundation

enum AuthValidation {
    static let passwordMinLength = 6

    static func emailError(_ email: String) -> String? {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return ValidationMessage.emailRequired }
        if !trimmed.contains("@") || !trimmed.contains(".") { return ValidationMessage.emailInvalid }
        return nil
    }

    static func passwordError(_ password: String) -> String? {
        if password.isEmpty { return ValidationMessage.passwordRequired }
        if password.count < passwordMinLength { return ValidationMessage.passwordTooShort(passwordMinLength) }
        return nil
    }

    static func confirmPasswordError(password: String, confirmation: String) -> String? {
        confirmation != password ? ValidationMessage.passwordsDoNotMatch : nil
    }
}
