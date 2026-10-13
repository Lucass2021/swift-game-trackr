import SwiftUI

enum SessionState {
    case unauthenticated
    case guest
    case authenticated
}

@MainActor
@Observable
class AuthStore {
    private(set) var state: SessionState
    private(set) var currentUser: User?
    var isResetFlowActive = false

    private let tokenStore: TokenStore
    private let repository: AuthRepository

    var isAuthenticated: Bool {
        state == .authenticated
    }

    var isGuest: Bool {
        state == .guest
    }

    var isInApp: Bool {
        state != .unauthenticated
    }

    init(tokenStore: TokenStore = KeychainTokenStore(), repository: AuthRepository = RemoteAuthRepository()) {
        self.tokenStore = tokenStore
        self.repository = repository
        state = tokenStore.get() != nil ? .authenticated : .unauthenticated
        Task { [weak self] in
            await APIClient.shared.setRefreshFailureHandler { [weak self] in
                Task { @MainActor [weak self] in
                    self?.logout()
                }
            }
        }
    }

    func validate() async {
        guard isAuthenticated else { return }
        do {
            currentUser = try await repository.validate()
        } catch APIError.unauthorized {
            logout()
        } catch {}
    }

    func updateUser(_ user: User) {
        currentUser = user
    }

    func continueAsGuest() {
        currentUser = nil
        state = .guest
        isResetFlowActive = false
    }

    func authenticate(user: User) {
        currentUser = user
        state = .authenticated
        isResetFlowActive = false
    }

    func logout() {
        tokenStore.clear()
        currentUser = nil
        state = .unauthenticated
        isResetFlowActive = false
    }
}
