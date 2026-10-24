import Testing
@testable import GameTrackr

@MainActor
struct AuthValidationTests {
    @Test func emailIsTrimmedBeforeValidation() {
        #expect(AuthValidation.emailError("  player@gametrackr.com \n") == nil)
        #expect(AuthValidation.emailError(" \n ") == "Email is required")
        #expect(AuthValidation.emailError("player@gametrackr") == "Enter a valid email")
    }

    @Test func passwordNeedsTheMinimumLength() {
        #expect(AuthValidation.passwordError("") == "Password is required")
        #expect(AuthValidation.passwordError("12345") == "At least 6 characters")
        #expect(AuthValidation.passwordError("123456") == nil)
    }

    @Test func confirmationMustMatchThePassword() {
        #expect(AuthValidation
            .confirmPasswordError(password: "secret123", confirmation: "secret12") == "Passwords do not match")
        #expect(AuthValidation.confirmPasswordError(password: "secret123", confirmation: "secret123") == nil)
    }
}
