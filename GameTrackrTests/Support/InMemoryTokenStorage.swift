import Foundation
@testable import GameTrackr

final class InMemoryTokenStorage: TokenStorage, @unchecked Sendable {
    private let lock = NSLock()
    private var token: String?

    init(token: String? = nil) {
        self.token = token
    }

    func get() -> String? {
        lock.withLock { token }
    }

    func save(_ token: String) {
        lock.withLock { self.token = token }
    }

    func clear() {
        lock.withLock { token = nil }
    }
}
