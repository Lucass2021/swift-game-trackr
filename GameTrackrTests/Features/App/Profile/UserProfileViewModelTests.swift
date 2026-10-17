import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct UserProfileViewModelTests {
    private static let user = UserProfileMockData.user
    private static let overlapLatency: Duration = .milliseconds(50)

    @Test func loadShowsTheHeaderStatsAndSectionsFromTheRepository() async {
        let viewModel = UserProfileViewModel(user: Self.user, repository: FakeProfileOverviewRepository(latency: .zero))

        await viewModel.loadIfNeeded()

        #expect(viewModel.profile?.bio == UserProfileMockData.bio)
        #expect(viewModel.profile?.username == Self.user.username)
        #expect(viewModel.overview?.stats.totalGames == UserProfileMockData.stats.totalGames)
        #expect(!viewModel.isFriend)
    }

    @Test func loadFailureShowsTheErrorStateInsteadOfLoadingForever() async {
        let viewModel = UserProfileViewModel(user: Self.user, repository: FakeProfileOverviewRepository(
            failure: APIError.networkFailure,
            latency: .zero
        ))

        await viewModel.loadIfNeeded()

        #expect(viewModel.hasError)
        #expect(!viewModel.isLoading)
    }

    @Test func retryAfterAFailureShowsTheProfile() async {
        let repository = FakeProfileOverviewRepository(failure: APIError.networkFailure, latency: .zero)
        let viewModel = UserProfileViewModel(user: Self.user, repository: repository)
        await viewModel.loadIfNeeded()

        await repository.setFailure(nil)
        await viewModel.load()

        #expect(viewModel.overview?.stats.totalGames == UserProfileMockData.stats.totalGames)
        #expect(!viewModel.hasError)
    }

    @Test func returningToTheScreenKeepsTheProfileWithoutFetchingAgain() async {
        let repository = FakeProfileOverviewRepository(latency: .zero)
        let viewModel = UserProfileViewModel(user: Self.user, repository: repository)
        await viewModel.loadIfNeeded()

        await viewModel.loadIfNeeded()

        #expect(await repository.fetchCount == 1)
    }

    @Test func addingAFriendSavesItAndSurvivesReopeningTheProfile() async {
        let repository = FakeProfileOverviewRepository(latency: .zero)
        let viewModel = UserProfileViewModel(user: Self.user, repository: repository)
        await viewModel.loadIfNeeded()

        await viewModel.onFriendAction(isGuest: false)
        let reopened = UserProfileViewModel(user: Self.user, repository: repository)
        await reopened.loadIfNeeded()

        #expect(viewModel.isFriend)
        #expect(await repository.isFriend(Self.user.username))
        #expect(reopened.isFriend)
    }

    @Test func aFriendFailureRestoresThePreviousStateAndShowsAnError() async {
        let repository = FakeProfileOverviewRepository(latency: .zero)
        let viewModel = UserProfileViewModel(user: Self.user, repository: repository)
        await viewModel.loadIfNeeded()

        await repository.setFailure(APIError.networkFailure)
        await viewModel.onFriendAction(isGuest: false)

        #expect(!viewModel.isFriend)
        #expect(viewModel.toastMessage == "Couldn't update friends. Please try again.")
    }

    @Test func aGuestGetsAToastAndNothingReachesTheRepository() async {
        let repository = FakeProfileOverviewRepository(latency: .zero)
        let viewModel = UserProfileViewModel(user: Self.user, repository: repository)
        await viewModel.loadIfNeeded()

        await viewModel.onFriendAction(isGuest: true)

        #expect(viewModel.toastMessage == "You're browsing as a guest. Create an account to add friends.")
        #expect(!viewModel.isFriend)
        #expect(await repository.setFriendCount == 0)

        viewModel.onMessage(isGuest: true)

        #expect(viewModel.toastMessage == "You're browsing as a guest. Create an account to send messages.")
    }

    @Test func aQuickSecondTapSupersedesTheFirstWithoutAnError() async {
        let repository = FakeProfileOverviewRepository(latency: Self.overlapLatency)
        let viewModel = UserProfileViewModel(user: Self.user, repository: repository)
        await viewModel.loadIfNeeded()

        let first = Task { await viewModel.onFriendAction(isGuest: false) }
        while await repository.setFriendCount == 0 {
            await Task.yield()
        }
        await viewModel.onFriendAction(isGuest: false)
        await first.value

        #expect(!viewModel.isFriend)
        #expect(await !repository.isFriend(Self.user.username))
        #expect(viewModel.toastMessage == nil)
    }
}
