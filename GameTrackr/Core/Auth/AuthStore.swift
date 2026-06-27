import SwiftUI

@MainActor
@Observable
class AuthStore {
    private(set) var isAuthenticated: Bool
    private(set) var currentUser: User?

    init() {
        isAuthenticated = KeychainHelper.getToken() != nil
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
        } catch {
        }
    }

    func authenticate(token: String, user: User) {
        KeychainHelper.saveToken(token)
        currentUser = user
        isAuthenticated = true
    }

    func logout() {
        KeychainHelper.clearToken()
        currentUser = nil
        isAuthenticated = false
    }
}
