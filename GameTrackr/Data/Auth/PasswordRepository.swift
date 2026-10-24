protocol PasswordRepository: Sendable {
    func changePassword(currentPassword: String, newPassword: String) async throws
}
