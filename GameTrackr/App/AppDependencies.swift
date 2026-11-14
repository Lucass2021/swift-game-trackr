import Observation

@MainActor
@Observable
final class AppDependencies {
    let authRepository: AuthRepository
    let googleAuth: GoogleAuth
    let gameRepository: GameRepository
    let libraryRepository: LibraryRepository
    let libraryUpdates = LibraryUpdates()
    let communityRepository: CommunityRepository
    let communityFeedRepository: CommunityFeedRepository
    let discoverCommunitiesRepository: DiscoverCommunitiesRepository
    let postUpdates = PostUpdates()
    let communityUpdates = CommunityUpdates()
    let profileOverviewRepository: ProfileOverviewRepository
    let profileRepository: ProfileRepository
    let setupRepository: SetupRepository
    let statsRepository: StatsRepository
    let achievementsRepository: AchievementsRepository
    let notificationsRepository: NotificationsRepository
    let notificationSettingsRepository: NotificationSettingsRepository
    let accountRepository: AccountRepository
    let passwordRepository: PasswordRepository

    init(
        authRepository: AuthRepository = RemoteAuthRepository(),
        googleAuth: GoogleAuth? = nil,
        gameRepository: GameRepository = RemoteGameRepository(),
        libraryRepository: LibraryRepository? = nil,
        communityRepository: CommunityRepository = RemoteCommunityRepository(),
        profileOverviewRepository: ProfileOverviewRepository? = nil,
        profileRepository: ProfileRepository = RemoteProfileRepository(),
        setupRepository: SetupRepository = RemoteSetupRepository()
    ) {
        self.authRepository = authRepository
        self.googleAuth = googleAuth ?? GoogleAuthService()
        self.gameRepository = gameRepository
        self.libraryRepository = libraryRepository ?? FakeLibraryRepository()
        self.communityRepository = communityRepository
        communityFeedRepository = FakeCommunityFeedRepository(remote: communityRepository)
        discoverCommunitiesRepository = FakeDiscoverCommunitiesRepository(remote: communityRepository)
        self.profileOverviewRepository = profileOverviewRepository ?? FakeProfileOverviewRepository()
        self.profileRepository = profileRepository
        self.setupRepository = setupRepository
        statsRepository = FakeStatsRepository()
        achievementsRepository = FakeAchievementsRepository()
        notificationsRepository = FakeNotificationsRepository()
        notificationSettingsRepository = FakeNotificationSettingsRepository()
        accountRepository = FakeAccountRepository()
        passwordRepository = FakePasswordRepository()
    }
}
