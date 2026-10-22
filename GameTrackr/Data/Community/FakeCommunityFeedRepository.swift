import Foundation

actor FakeCommunityFeedRepository: CommunityFeedRepository {
    private static let suggestionPoolSize = 30

    private(set) var fetchFeedCount = 0
    private(set) var setBookmarkCount = 0
    private let remote: CommunityRepository
    private let followingPosts: [CommunityPost]
    private var bookmarkedIds: Set<Int> = []
    private var failure: Error?
    private let latency: Duration

    init(
        remote: CommunityRepository,
        followingPosts: [CommunityPost] = CommunityMockData.feed,
        failure: Error? = nil,
        latency: Duration = FakeLatency.responseDelay
    ) {
        self.remote = remote
        self.followingPosts = followingPosts
        self.failure = failure
        self.latency = latency
    }

    func fetchFeed(filter: CommunityFeedFilter, page: Int, perPage: Int) async throws -> Page<CommunityPost> {
        fetchFeedCount += 1
        if let failure { throw failure }
        let result: Page<CommunityPost>
        switch filter {
        case .latest, .topRated:
            result = try await remote.fetchPosts(page: page, perPage: perPage, communityId: nil)
        case .following:
            try await Task.sleep(for: latency)
            result = fakePage(items: followingPosts, page: page, perPage: perPage)
        }
        var items = filter == .topRated ? result.items.sorted { $0.likes > $1.likes } : result.items
        for index in items.indices {
            items[index].isBookmarked = bookmarkedIds.contains(items[index].id)
        }
        return Page(items: items, currentPage: result.currentPage, lastPage: result.lastPage, total: result.total)
    }

    func fetchSuggestedCommunity() async throws -> Community? {
        if let failure { throw failure }
        let page = try await remote.fetchCommunities(page: 1, perPage: Self.suggestionPoolSize, search: nil)
        return page.items.first { !$0.isJoined }
    }

    func setBookmark(postId: Int, isBookmarked: Bool) async throws {
        setBookmarkCount += 1
        try await Task.sleep(for: latency)
        if let failure { throw failure }
        if isBookmarked {
            bookmarkedIds.insert(postId)
        } else {
            bookmarkedIds.remove(postId)
        }
    }

    func setFailure(_ error: Error?) {
        failure = error
    }

    func isBookmarked(_ postId: Int) -> Bool {
        bookmarkedIds.contains(postId)
    }
}
