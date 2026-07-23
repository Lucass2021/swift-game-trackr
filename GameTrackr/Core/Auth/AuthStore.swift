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

    var isAuthenticated: Bool {
        state == .authenticated
    }

    var isGuest: Bool {
        state == .guest
    }

    var isInApp: Bool {
        state != .unauthenticated
    }

    init() {
        state = KeychainHelper.getToken() != nil ? .authenticated : .unauthenticated
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
            let response: ValidateResponse = try await APIClient.shared.request(.validateToken)
            currentUser = response.user
        } catch {}
    }

    func continueAsGuest() {
        currentUser = nil
        state = .guest
        isResetFlowActive = false
    }

    func authenticate(token: String, user: User) {
        KeychainHelper.saveToken(token)
        currentUser = user
        state = .authenticated
        isResetFlowActive = false
    }

    func logout() {
        KeychainHelper.clearToken()
        currentUser = nil
        state = .unauthenticated
        isResetFlowActive = false
    }
}
