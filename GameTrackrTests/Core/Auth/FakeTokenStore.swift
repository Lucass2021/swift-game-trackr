import Synchronization
@testable import GameTrackr

final class FakeTokenStore: TokenStore {
    private let token = Mutex<String?>(nil)

    func get() -> String? {
        token.withLock { $0 }
    }

    func save(_ token: String) {
        self.token.withLock { $0 = token }
    }

    func clear() {
        token.withLock { $0 = nil }
    }
}
