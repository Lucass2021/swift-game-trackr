import Foundation

actor FakeAccountRepository: AccountRepository {
    private(set) var deleteCount = 0
    private var failure: Error?
    private let latency: Duration

    init(failure: Error? = nil, latency: Duration = FakeLatency.responseDelay) {
        self.failure = failure
        self.latency = latency
    }

    func deleteAccount() async throws {
        deleteCount += 1
        try await Task.sleep(for: latency)
        if let failure { throw failure }
    }

    func setFailure(_ error: Error?) {
        failure = error
    }
}
