import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct GameDetailViewModelTests {
    private static let slug = "neon-ascent-revival"
    private static let overlapLatency: Duration = .milliseconds(50)

    @Test func loadShowsTheGameFromTheRepository() async {
        let viewModel = GameDetailViewModel(slug: Self.slug, repository: FakeGameRepository(latency: .zero))

        await viewModel.loadIfNeeded()

        #expect(viewModel.game?.title == FakeGameRepository.gameDetail.title)
        #expect(!viewModel.isLoading)
        #expect(!viewModel.hasError)
    }

    @Test func loadFailureShowsTheErrorStateInsteadOfLoadingForever() async {
        let repository = FakeGameRepository(fetchGameFailure: APIError.networkFailure, latency: .zero)
        let viewModel = GameDetailViewModel(slug: Self.slug, repository: repository)

        await viewModel.loadIfNeeded()

        #expect(viewModel.hasError)
        #expect(!viewModel.isLoading)
        #expect(viewModel.game == nil)
    }

    @Test func retryAfterAFailureShowsTheGame() async {
        let repository = FakeGameRepository(fetchGameFailure: APIError.networkFailure, latency: .zero)
        let viewModel = GameDetailViewModel(slug: Self.slug, repository: repository)
        await viewModel.loadIfNeeded()

        await repository.setFetchGameFailure(nil)
        await viewModel.load()

        #expect(viewModel.game?.title == FakeGameRepository.gameDetail.title)
        #expect(!viewModel.hasError)
    }

    @Test func returningToTheScreenKeepsTheGameWithoutFetchingAgain() async {
        let repository = FakeGameRepository(latency: .zero)
        let viewModel = GameDetailViewModel(slug: Self.slug, repository: repository)
        await viewModel.loadIfNeeded()

        await viewModel.loadIfNeeded()

        #expect(await repository.fetchGameCount == 1)
    }

    @Test func aSecondAppearanceWhileLoadingDoesNotStartAnotherRequest() async {
        let repository = FakeGameRepository(latency: Self.overlapLatency)
        let viewModel = GameDetailViewModel(slug: Self.slug, repository: repository)

        async let first: Void = viewModel.loadIfNeeded()
        await Task.yield()
        await viewModel.loadIfNeeded()
        await first

        #expect(await repository.fetchGameCount == 1)
    }
}
