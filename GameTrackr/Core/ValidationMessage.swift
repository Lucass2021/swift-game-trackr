import Foundation

enum ValidationMessage {
    static let nameRequired = "Full name is required"
    static let nameTooShort = "At least 3 characters"
    static let emailRequired = "Email is required"
    static let emailInvalid = "Enter a valid email"
    static let passwordRequired = "Password is required"
    static let passwordTooShort = "At least 6 characters"
    static let passwordsDoNotMatch = "Passwords do not match"
    static let termsRequired = "You must accept the terms to continue"
    static let codeRequired = "Code is required"
    static let codeInvalid = "Enter the 6-digit code"
}
