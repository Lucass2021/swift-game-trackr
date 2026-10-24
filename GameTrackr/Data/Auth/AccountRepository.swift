protocol AccountRepository: Sendable {
    func deleteAccount() async throws
}
