import SwiftUI

@MainActor
@Observable
class VerifyResetCodeViewModel {
    let email: String
    var code = ""
    var isLoading = false
    var errorMessage: String?
    var showResetPassword = false
    var secondsRemaining = 30
    private var submitted = false

    private let service: AuthServicing

    init(email: String, service: AuthServicing = AuthService.live) {
        self.email = email
        self.service = service
    }

    var codeError: String? {
        guard submitted else { return nil }
        if code.trimmingCharacters(in: .whitespaces).isEmpty { return ValidationMessage.codeRequired }
        if code.count != 6 { return ValidationMessage.codeInvalid }
        return nil
    }

    var canResend: Bool { secondsRemaining <= 0 }

    func startResendCountdown() async {
        secondsRemaining = 30
        while secondsRemaining > 0 {
            try? await Task.sleep(for: .seconds(1))
            secondsRemaining -= 1
        }
    }

    func resend() async {
        guard canResend else { return }
        try? await service.forgotPassword(email: email)
        await startResendCountdown()
    }

    func verify() async {
        guard !isLoading else { return }
        submitted = true
        guard codeError == nil else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await service.verifyResetCode(email: email, code: code)
            showResetPassword = true
        } catch {
            errorMessage = error.userMessage()
        }
    }
}
