import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct GameAchievementsViewModelTests {
    private static let overlapLatency: Duration = .milliseconds(50)
    private static let game = AchievementsMockData.games[4]
    private static let unknownGameId = -1

    @Test func loadShowsTheGameWithUnlockedAndLockedAchievementsApart() async {
        let viewModel = GameAchievementsViewModel(
            gameId: Self.game.id,
            repository: FakeAchievementsRepository(latency: .zero)
        )

        await viewModel.loadIfNeeded()

        #expect(viewModel.game?.id == Self.game.id)
        #expect(viewModel.unlockedAchievements.map(\.id) == Self.game.achievements.filter(\.isUnlocked).map(\.id))
        #expect(viewModel.lockedAchievements.map(\.id) == Self.game.achievements.filter { !$0.isUnlocked }.map(\.id))
        #expect(!viewModel.unlockedAchievements.isEmpty)
        #expect(!viewModel.lockedAchievements.isEmpty)
    }

    @Test func loadFailureShowsTheErrorStateInsteadOfLoadingForever() async {
        let viewModel = GameAchievementsViewModel(
            gameId: Self.game.id,
            repository: FakeAchievementsRepository(failure: APIError.networkFailure, latency: .zero)
        )

        await viewModel.loadIfNeeded()

        #expect(viewModel.hasError)
        #expect(!viewModel.isLoading)
    }

    @Test func anUnknownGameShowsTheErrorState() async {
        let viewModel = GameAchievementsViewModel(
            gameId: Self.unknownGameId,
            repository: FakeAchievementsRepository(latency: .zero)
        )

        await viewModel.loadIfNeeded()

        #expect(viewModel.hasError)
        #expect(viewModel.game == nil)
    }

    @Test func retryAfterAFailureShowsTheGame() async {
        let repository = FakeAchievementsRepository(failure: APIError.networkFailure, latency: .zero)
        let viewModel = GameAchievementsViewModel(gameId: Self.game.id, repository: repository)
        await viewModel.loadIfNeeded()

        await repository.setFailure(nil)
        await viewModel.load()

        #expect(viewModel.game?.id == Self.game.id)
        #expect(!viewModel.hasError)
    }

    @Test func returningToTheScreenKeepsTheGameWithoutFetchingAgain() async {
        let repository = FakeAchievementsRepository(latency: .zero)
        let viewModel = GameAchievementsViewModel(gameId: Self.game.id, repository: repository)
        await viewModel.loadIfNeeded()

        await viewModel.loadIfNeeded()

        #expect(await repository.gameFetchCount == 1)
        #expect(viewModel.game?.id == Self.game.id)
    }

    @Test func aRetryReplacesTheLoadInFlight() async {
        let repository = FakeAchievementsRepository(latency: Self.overlapLatency)
        let viewModel = GameAchievementsViewModel(gameId: Self.game.id, repository: repository)

        let loading = Task { await viewModel.loadIfNeeded() }
        while await repository.gameFetchCount == 0 {
            await Task.yield()
        }
        await viewModel.load()
        await loading.value

        #expect(await repository.gameFetchCount == 2)
        #expect(viewModel.game?.id == Self.game.id)
        #expect(!viewModel.isLoading)
    }
}
