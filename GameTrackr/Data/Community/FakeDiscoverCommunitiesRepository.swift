import Foundation

actor FakeDiscoverCommunitiesRepository: DiscoverCommunitiesRepository {
    private(set) var fetchCount = 0
    private(set) var lastSearch: String?
    private(set) var setJoinedCount = 0
    private let remote: CommunityRepository
    private let categoryCommunities: [Community]
    private let mockIds: Set<Int>
    private var joinedMockIds: Set<Int>
    private var failure: Error?
    private let latency: Duration

    init(
        remote: CommunityRepository,
        categoryCommunities: [Community] = DiscoverMockData.categoryCommunities,
        failure: Error? = nil,
        latency: Duration = FakeLatency.responseDelay
    ) {
        self.remote = remote
        self.categoryCommunities = categoryCommunities
        mockIds = Set(categoryCommunities.map(\.id))
        joinedMockIds = Set(categoryCommunities.filter(\.isJoined).map(\.id))
        self.failure = failure
        self.latency = latency
    }

    func fetchCommunities(category: String?, search: String?, page: Int, perPage: Int) async throws -> Page<Community> {
        fetchCount += 1
        lastSearch = search
        if let failure { throw failure }
        guard let category else {
            return try await remote.fetchCommunities(page: page, perPage: perPage, search: search)
        }
        try await Task.sleep(for: latency)
        let query = search ?? ""
        var matches = categoryCommunities.filter {
            $0.category == category && (query.isEmpty || $0.name.localizedCaseInsensitiveContains(query))
        }
        for index in matches.indices {
            matches[index].isJoined = joinedMockIds.contains(matches[index].id)
        }
        return fakePage(items: matches, page: page, perPage: perPage)
    }

    func setJoined(communityId: Int, isJoined: Bool) async throws {
        setJoinedCount += 1
        if let failure { throw failure }
        guard mockIds.contains(communityId) else {
            if isJoined {
                try await remote.joinCommunity(id: communityId)
            } else {
                try await remote.leaveCommunity(id: communityId)
            }
            return
        }
        try await Task.sleep(for: latency)
        if isJoined {
            joinedMockIds.insert(communityId)
        } else {
            joinedMockIds.remove(communityId)
        }
    }

    func setFailure(_ error: Error?) {
        failure = error
    }
}
