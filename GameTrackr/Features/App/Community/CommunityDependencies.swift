@MainActor
final class CommunityDependencies {
    let repository: CommunityRepository
    let feedRepository: CommunityFeedRepository
    let postUpdates = PostUpdates()
    let communityUpdates = CommunityUpdates()
    let discoverRepository: DiscoverCommunitiesRepository
    let feedViewModel: CommunityFeedViewModel
    let discoverViewModel: DiscoverCommunitiesViewModel

    init(repository: CommunityRepository = RemoteCommunityRepository()) {
        self.repository = repository
        feedRepository = FakeCommunityFeedRepository(remote: repository)
        discoverRepository = FakeDiscoverCommunitiesRepository(remote: repository)
        feedViewModel = CommunityFeedViewModel(
            feedRepository: feedRepository,
            repository: repository,
            postUpdates: postUpdates,
            communityUpdates: communityUpdates
        )
        discoverViewModel = DiscoverCommunitiesViewModel(
            repository: discoverRepository,
            communityUpdates: communityUpdates
        )
    }
}
