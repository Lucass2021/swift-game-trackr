protocol ProfileOverviewRepository: Sendable {
    func fetchMyOverview() async throws -> ProfileOverview
    func fetchUserOverview(username: String) async throws -> ProfileOverview
}
