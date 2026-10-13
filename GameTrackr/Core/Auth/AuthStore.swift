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

    var isAuthenticated: Bool {
        state == .authenticated
    }

    var isGuest: Bool {
        state == .guest
    }

    var isInApp: Bool {
        state != .unauthenticated
    }

    init(tokenStore: TokenStore = KeychainTokenStore()) {
        self.tokenStore = tokenStore
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
            let response: ValidateResponse = try await APIClient.shared.request(.me)
            currentUser = response.user
        } catch APIError.unauthorized {
            logout()
        } catch {}
    }

    func completeSocialSignIn(token: String) async throws {
        tokenStore.save(token)
        do {
            let response: ValidateResponse = try await APIClient.shared.request(.me)
            authenticate(token: token, user: response.user)
        } catch {
            tokenStore.clear()
            throw error
        }
    }

    func updateUser(_ user: User) {
        currentUser = user
    }

    func continueAsGuest() {
        currentUser = nil
        state = .guest
        isResetFlowActive = false
    }

    func authenticate(token: String, user: User) {
        tokenStore.save(token)
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
