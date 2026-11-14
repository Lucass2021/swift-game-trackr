import Observation

@MainActor
@Observable
final class AppDependencies {
    let gameRepository: GameRepository
    let libraryRepository: LibraryRepository
    let libraryUpdates = LibraryUpdates()
    let communityRepository: CommunityRepository
    let communityFeedRepository: CommunityFeedRepository
    let discoverCommunitiesRepository: DiscoverCommunitiesRepository
    let postUpdates = PostUpdates()
    let communityUpdates = CommunityUpdates()
    let profileOverviewRepository: ProfileOverviewRepository

    init(
        gameRepository: GameRepository = RemoteGameRepository(),
        libraryRepository: LibraryRepository? = nil,
        communityRepository: CommunityRepository = RemoteCommunityRepository(),
        profileOverviewRepository: ProfileOverviewRepository? = nil
    ) {
        self.gameRepository = gameRepository
        self.libraryRepository = libraryRepository ?? FakeLibraryRepository()
        self.communityRepository = communityRepository
        communityFeedRepository = FakeCommunityFeedRepository(remote: communityRepository)
        discoverCommunitiesRepository = FakeDiscoverCommunitiesRepository(remote: communityRepository)
        self.profileOverviewRepository = profileOverviewRepository ?? FakeProfileOverviewRepository()
    }
}
