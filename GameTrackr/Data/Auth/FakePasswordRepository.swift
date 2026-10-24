import Foundation

actor FakePasswordRepository: PasswordRepository {
    private(set) var changeCount = 0
    private(set) var lastCurrentPassword: String?
    private(set) var lastNewPassword: String?
    private var failure: Error?
    private let latency: Duration

    init(failure: Error? = nil, latency: Duration = FakeLatency.responseDelay) {
        self.failure = failure
        self.latency = latency
    }

    func changePassword(currentPassword: String, newPassword: String) async throws {
        changeCount += 1
        try await Task.sleep(for: latency)
        if let failure { throw failure }
        lastCurrentPassword = currentPassword
        lastNewPassword = newPassword
    }

    func setFailure(_ error: Error?) {
        failure = error
    }
}
