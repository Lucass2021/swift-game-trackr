import Foundation

@MainActor
@Observable
final class VerifyResetCodeViewModel {
    static let codeLength = 6
    static let resendSeconds = 30

    let email: String
    private(set) var code = ""
    private(set) var isSubmitted = false
    private(set) var isLoading = false
    private(set) var resendSeconds = VerifyResetCodeViewModel.resendSeconds
    private(set) var verifyTask: Task<Void, Never>?
    var verifiedCode: String?
    var toastMessage: String?

    private let repository: AuthRepository
    private let tick: Duration
    private var countdownTask: Task<Void, Never>?

    init(email: String, repository: AuthRepository = RemoteAuthRepository(), tick: Duration = .seconds(1)) {
        self.email = email
        self.repository = repository
        self.tick = tick
        startCountdown()
    }

    var codeError: String? {
        isSubmitted ? Self.codeError(for: code) : nil
    }

    var canSubmit: Bool {
        Self.codeError(for: code) == nil
    }

    var canResend: Bool {
        resendSeconds <= 0
    }

    func onCodeChange(_ value: String) {
        let digits = String(value.filter { ("0" ... "9").contains($0) }.prefix(Self.codeLength))
        guard digits != code else { return }
        code = digits
        if code.count == Self.codeLength {
            verifyTask = Task { await submit() }
        }
    }

    func submit() async {
        guard !isLoading else { return }
        isSubmitted = true
        guard canSubmit else { return }

        let submittedCode = code
        isLoading = true
        toastMessage = nil
        defer { isLoading = false }

        do {
            try await repository.verifyResetCode(email: email, code: submittedCode)
            verifiedCode = submittedCode
        } catch {
            toastMessage = error.userMessage()
        }
    }

    func resend() async {
        guard canResend else { return }
        startCountdown()
        do {
            try await repository.forgotPassword(email: email)
        } catch {
            countdownTask?.cancel()
            resendSeconds = 0
            toastMessage = error.userMessage()
        }
    }

    private func startCountdown() {
        countdownTask?.cancel()
        resendSeconds = Self.resendSeconds
        countdownTask = Task { [weak self, tick] in
            while !Task.isCancelled {
                try? await Task.sleep(for: tick)
                guard let self, !Task.isCancelled else { return }
                resendSeconds -= 1
                if resendSeconds <= 0 { return }
            }
        }
    }

    private static func codeError(for code: String) -> String? {
        if code.isEmpty { return ValidationMessage.codeRequired }
        if code.count != codeLength { return ValidationMessage.codeInvalid(codeLength) }
        return nil
    }
}
