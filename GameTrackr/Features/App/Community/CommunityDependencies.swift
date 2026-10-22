@MainActor
final class CommunityDependencies {
    let repository: CommunityRepository
    let feedRepository: CommunityFeedRepository
    let postUpdates = PostUpdates()
    let communityUpdates = CommunityUpdates()
    let feedViewModel: CommunityFeedViewModel

    init(repository: CommunityRepository = RemoteCommunityRepository()) {
        self.repository = repository
        feedRepository = FakeCommunityFeedRepository(remote: repository)
        feedViewModel = CommunityFeedViewModel(
            feedRepository: feedRepository,
            repository: repository,
            postUpdates: postUpdates,
            communityUpdates: communityUpdates
        )
    }
}
