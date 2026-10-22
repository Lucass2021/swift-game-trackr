protocol CommunityFeedRepository: Sendable {
    func fetchFeed(filter: CommunityFeedFilter, page: Int, perPage: Int) async throws -> Page<CommunityPost>
    func fetchSuggestedCommunity() async throws -> Community?
    func setBookmark(postId: Int, isBookmarked: Bool) async throws
}
