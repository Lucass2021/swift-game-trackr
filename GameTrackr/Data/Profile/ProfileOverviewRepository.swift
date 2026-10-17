protocol ProfileOverviewRepository: Sendable {
    func fetchMyOverview() async throws -> ProfileOverview
    func fetchUserOverview(username: String) async throws -> UserOverview
    func setFriend(username: String, isFriend: Bool) async throws
}
