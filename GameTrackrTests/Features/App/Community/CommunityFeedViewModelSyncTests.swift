import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct CommunityFeedViewModelSyncTests {
    private static let overlapLatency: Duration = .milliseconds(50)

    private let repository = FakeCommunityRepository(latency: .zero)
    private let communityUpdates = CommunityUpdates()
    private let feed: CommunityFeedViewModel
    private let discover: DiscoverCommunitiesViewModel

    init() {
        feed = CommunityFeedViewModel(
            feedRepository: FakeCommunityFeedRepository(remote: repository, latency: .zero),
            repository: repository,
            postUpdates: PostUpdates(),
            communityUpdates: communityUpdates
        )
        discover = DiscoverCommunitiesViewModel(
            repository: FakeDiscoverCommunitiesRepository(remote: repository, latency: .zero),
            communityUpdates: communityUpdates
        )
    }

    private func loaded() async {
        await feed.loadIfNeeded()
        await discover.loadIfNeeded()
    }

    private static func manyPosts() -> [CommunityPost] {
        let base = CommunityMockData.communityPosts[0]
        return (0 ..< CommunityFeedViewModel.pageSize + 5).map { offset in
            CommunityPost(
                id: 1000 + offset,
                author: base.author,
                timeAgo: base.timeAgo,
                communityName: base.communityName,
                title: base.title,
                preview: base.preview,
                likes: base.likes,
                comments: base.comments,
                hasMedia: false
            )
        }
    }

    @Test func joiningInDiscoverUpdatesTheSuggestedCommunity() async throws {
        await loaded()
        let suggestion = try #require(feed.suggestedCommunity)
        let community = try #require(discover.communities.first { $0.id == suggestion.id })

        await discover.onJoinTap(community)

        #expect(feed.suggestedCommunity?.isJoined == true)
    }

    @Test func joiningTheSuggestedCommunityUpdatesDiscover() async throws {
        await loaded()
        let suggestion = try #require(feed.suggestedCommunity)

        await feed.onJoinSuggested()

        #expect(discover.communities.first { $0.id == suggestion.id }?.isJoined == true)
    }

    @Test func tappingASuggestionAlreadyJoinedSendsNoRequest() async throws {
        await loaded()
        await feed.onJoinSuggested()

        await repository.setFailure(APIError.networkFailure)
        await feed.onJoinSuggested()

        #expect(try #require(feed.suggestedCommunity).isJoined)
        #expect(feed.toastMessage == nil)
    }

    @Test func aLoadMoreDuringARefreshDoesNotCancelTheRefresh() async {
        let repository = FakeCommunityRepository(posts: Self.manyPosts(), latency: Self.overlapLatency)
        let feed = CommunityFeedViewModel(
            feedRepository: FakeCommunityFeedRepository(remote: repository, latency: .zero),
            repository: repository,
            postUpdates: PostUpdates(),
            communityUpdates: communityUpdates
        )
        await feed.loadIfNeeded()

        let refreshing = Task { await feed.refresh() }
        while await repository.fetchPostsCount < 2 {
            await Task.yield()
        }
        await feed.loadMore()
        await refreshing.value

        #expect(!feed.isRefreshing)
        #expect(feed.currentPage == 1)
        #expect(feed.posts.count == CommunityFeedViewModel.pageSize)
    }

    @Test func changingTheFilterWhileAPageLoadsShowsOnlyTheNewFilter() async {
        let repository = FakeCommunityRepository(latency: Self.overlapLatency)
        let feed = CommunityFeedViewModel(
            feedRepository: FakeCommunityFeedRepository(remote: repository, latency: .zero),
            repository: repository,
            postUpdates: PostUpdates(),
            communityUpdates: communityUpdates
        )
        await feed.loadIfNeeded()

        let topRated = Task { await feed.onFilterChange(.topRated) }
        while await repository.fetchPostsCount < 2 {
            await Task.yield()
        }
        await feed.onFilterChange(.following)
        await topRated.value

        #expect(feed.posts.map(\.id) == CommunityMockData.feed.map(\.id))
    }
}
