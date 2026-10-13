nonisolated protocol TokenStore: Sendable {
    func get() -> String?
    func save(_ token: String)
    func clear()
}
