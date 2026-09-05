import Foundation

protocol TokenStorage: Sendable {
    func get() -> String?
    func save(_ token: String)
    func clear()
}

struct KeychainTokenStorage: TokenStorage {
    func get() -> String? {
        KeychainHelper.getToken()
    }

    func save(_ token: String) {
        KeychainHelper.saveToken(token)
    }

    func clear() {
        KeychainHelper.clearToken()
    }
}
