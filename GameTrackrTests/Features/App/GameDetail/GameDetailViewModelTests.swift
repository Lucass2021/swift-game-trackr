import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct GameDetailViewModelTests {
    private static let slug = "neon-ascent-revival"
    private static let otherSlug = "another-game"
    private static let newEntry = NewLibraryEntry(
        title: "Neon Ascent: Revival",
        slug: slug,
        status: .playing,
        rating: 0,
        hours: nil,
        platform: nil,
        startedAt: nil,
        finishedAt: nil,
        review: nil,
        coverStart: .coverVioletStart,
        coverEnd: .coverVioletEnd
    )
    private static let overlapLatency: Duration = .milliseconds(50)

    private func viewModel(
        repository: FakeGameRepository,
        libraryRepository: FakeLibraryRepository? = nil,
        libraryUpdates: LibraryUpdates? = nil
    ) -> GameDetailViewModel {
        GameDetailViewModel(
            slug: Self.slug,
            repository: repository,
            libraryRepository: libraryRepository ?? FakeLibraryRepository(entries: [], latency: .zero),
            libraryUpdates: libraryUpdates ?? LibraryUpdates()
        )
    }

    @Test func loadShowsTheGameFromTheRepository() async {
        let viewModel = viewModel(repository: FakeGameRepository(latency: .zero))

        await viewModel.loadIfNeeded()

        #expect(viewModel.game?.title == FakeGameRepository.gameDetail.title)
        #expect(!viewModel.isLoading)
        #expect(!viewModel.hasError)
    }

    @Test func loadFailureShowsTheErrorStateInsteadOfLoadingForever() async {
        let repository = FakeGameRepository(fetchGameFailure: APIError.networkFailure, latency: .zero)
        let viewModel = viewModel(repository: repository)

        await viewModel.loadIfNeeded()

        #expect(viewModel.hasError)
        #expect(!viewModel.isLoading)
        #expect(viewModel.game == nil)
    }

    @Test func retryAfterAFailureShowsTheGame() async {
        let repository = FakeGameRepository(fetchGameFailure: APIError.networkFailure, latency: .zero)
        let viewModel = viewModel(repository: repository)
        await viewModel.loadIfNeeded()

        await repository.setFetchGameFailure(nil)
        await viewModel.load()

        #expect(viewModel.game?.title == FakeGameRepository.gameDetail.title)
        #expect(!viewModel.hasError)
    }

    @Test func returningToTheScreenKeepsTheGameWithoutFetchingAgain() async {
        let repository = FakeGameRepository(latency: .zero)
        let viewModel = viewModel(repository: repository)
        await viewModel.loadIfNeeded()

        await viewModel.loadIfNeeded()

        #expect(await repository.fetchGameCount == 1)
    }

    @Test func addingTheGameToTheLibraryShowsTheConfirmation() {
        let viewModel = viewModel(repository: FakeGameRepository(latency: .zero))

        viewModel.onAddedToLibrary()

        #expect(viewModel.toastMessage == "Added to your library")
    }

    @Test func aGameAlreadyInTheLibraryShowsIt() async throws {
        let libraryRepository = FakeLibraryRepository(entries: [], latency: .zero)
        try await libraryRepository.addToLibrary(Self.newEntry)
        let viewModel = viewModel(repository: FakeGameRepository(latency: .zero), libraryRepository: libraryRepository)

        await viewModel.loadIfNeeded()

        #expect(viewModel.isInLibrary)
    }

    @Test func savingThisGameFromTheSheetMarksItAsInTheLibrary() async {
        let libraryUpdates = LibraryUpdates()
        let viewModel = viewModel(repository: FakeGameRepository(latency: .zero), libraryUpdates: libraryUpdates)
        await viewModel.loadIfNeeded()
        #expect(!viewModel.isInLibrary)

        libraryUpdates.publish(Self.otherSlug)
        #expect(!viewModel.isInLibrary)

        libraryUpdates.publish(Self.slug)
        #expect(viewModel.isInLibrary)
    }

    @Test func aSecondAppearanceWhileLoadingDoesNotStartAnotherRequest() async {
        let repository = FakeGameRepository(latency: Self.overlapLatency)
        let viewModel = viewModel(repository: repository)

        async let first: Void = viewModel.loadIfNeeded()
        await Task.yield()
        await viewModel.loadIfNeeded()
        await first

        #expect(await repository.fetchGameCount == 1)
    }
}
