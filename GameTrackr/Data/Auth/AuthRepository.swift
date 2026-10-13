protocol AuthRepository: Sendable {
    func login(email: String, password: String) async throws -> User
    func register(name: String, email: String, password: String, passwordConfirmation: String) async throws -> User
    func signInWithGoogle(token: String) async throws -> User
    func validate() async throws -> User
    func forgotPassword(email: String) async throws
    func verifyResetCode(email: String, code: String) async throws
    func resetPassword(email: String, code: String, newPassword: String) async throws
}
