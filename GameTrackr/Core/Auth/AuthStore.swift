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

    private let client: APIClient
    private let tokenStorage: TokenStorage

    init(client: APIClient = .shared, tokenStorage: TokenStorage = KeychainTokenStorage()) {
        self.client = client
        self.tokenStorage = tokenStorage
        state = tokenStorage.get() != nil ? .authenticated : .unauthenticated
        Task {
            await client.setRefreshFailureHandler { [weak self] in
                Task { @MainActor [weak self] in
                    self?.logout()
                }
            }
        }
    }

    func validate() async {
        guard isAuthenticated else { return }
        do {
            let response: ValidateResponse = try await client.request(.me)
            currentUser = response.user
        } catch APIError.unauthorized {
            logout()
        } catch {}
    }

    func completeSocialSignIn(token: String) async throws {
        tokenStorage.save(token)
        do {
            let response: ValidateResponse = try await client.request(.me)
            authenticate(token: token, user: response.user)
        } catch {
            tokenStorage.clear()
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
        tokenStorage.save(token)
        currentUser = user
        state = .authenticated
        isResetFlowActive = false
    }

    func logout() {
        tokenStorage.clear()
        currentUser = nil
        state = .unauthenticated
        isResetFlowActive = false
    }
}
