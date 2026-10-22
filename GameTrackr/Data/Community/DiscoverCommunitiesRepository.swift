protocol DiscoverCommunitiesRepository: Sendable {
    func fetchCommunities(category: String?, search: String?, page: Int, perPage: Int) async throws -> Page<Community>
    func setJoined(communityId: Int, isJoined: Bool) async throws
}
