import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct AddToLibraryViewModelTests {
    private static let slug = "neon-ascent-revival"
    private static let userId = 7
    private static let rating = 4
    private static let hours = "42"
    private static let review = "Great climb."
    private static let earlier = Date(timeIntervalSince1970: 1_709_251_200)
    private static let later = Date(timeIntervalSince1970: 1_710_417_600)
    private static let overlapLatency: Duration = .milliseconds(50)

    private func viewModel(
        repository: FakeLibraryRepository,
        libraryUpdates: LibraryUpdates? = nil,
        platforms: [String]? = nil
    ) -> AddToLibraryViewModel {
        let base = FakeGameRepository.gameDetail
        let game = GameDetail(
            title: base.title,
            year: base.year,
            rating: base.rating,
            platforms: platforms ?? base.platforms,
            genres: base.genres,
            coverStart: base.coverStart,
            coverEnd: base.coverEnd,
            heroURL: base.heroURL,
            screenshots: base.screenshots,
            about: base.about,
            specs: base.specs
        )
        return AddToLibraryViewModel(
            slug: Self.slug,
            game: game,
            repository: repository,
            libraryUpdates: libraryUpdates ?? LibraryUpdates()
        )
    }

    @Test func savingAddsTheGameToTheLibraryAndTellsTheLibraryScreen() async throws {
        let repository = FakeLibraryRepository(entries: [], latency: .zero)
        let libraryUpdates = LibraryUpdates()
        let library = LibraryViewModel(repository: repository, libraryUpdates: libraryUpdates)
        await library.loadFor(Self.userId)
        let viewModel = viewModel(repository: repository, libraryUpdates: libraryUpdates)

        viewModel.onStatusChange(.completed)
        viewModel.onRatingChange(Self.rating)
        viewModel.onHoursChange(Self.hours)
        await viewModel.onSave()
        await library.updateTask?.value

        let entry = try #require(await repository.entry(Self.slug))
        #expect(entry.status == .completed)
        #expect(entry.rating == Self.rating)
        #expect(entry.hours == 42)
        #expect(entry.title == FakeGameRepository.gameDetail.title)
        #expect(viewModel.isSaved)
        #expect(library.entries.map(\.slug) == [Self.slug])
    }

    @Test func thePlatformChoicesComeFromTheGame() {
        let viewModel = viewModel(repository: FakeLibraryRepository(latency: .zero), platforms: ["Switch", "PC"])

        #expect(viewModel.platforms == ["Switch", "PC"])
        #expect(viewModel.platform == "Switch")
    }

    @Test func aGameWithoutPlatformsHasNoPlatformToPick() {
        let viewModel = viewModel(repository: FakeLibraryRepository(latency: .zero), platforms: [])

        #expect(viewModel.platform == nil)
    }

    @Test func aFinishDateBeforeTheStartDateShowsTheErrorAndDoesNotSave() async {
        let repository = FakeLibraryRepository(latency: .zero)
        let viewModel = viewModel(repository: repository)
        viewModel.onStartedChange(Self.later)
        viewModel.onFinishedChange(Self.earlier)

        await viewModel.onSave()

        #expect(viewModel.dateError != nil)
        #expect(await repository.addCount == 0)
    }

    @Test func theDateErrorOnlyShowsAfterTryingToSave() {
        let viewModel = viewModel(repository: FakeLibraryRepository(latency: .zero))
        viewModel.onStartedChange(Self.later)
        viewModel.onFinishedChange(Self.earlier)

        #expect(viewModel.dateError == nil)
    }

    @Test func aSaveFailureKeepsTheFormAndShowsTheToast() async {
        let viewModel = viewModel(repository: FakeLibraryRepository(failure: APIError.networkFailure, latency: .zero))
        viewModel.onReviewChange(Self.review)

        await viewModel.onSave()

        #expect(viewModel.toastMessage != nil)
        #expect(viewModel.review == Self.review)
        #expect(!viewModel.isSaved)
        #expect(!viewModel.isSaving)
    }

    @Test func aDoubleTapOnSaveAddsTheGameOnce() async {
        let repository = FakeLibraryRepository(latency: Self.overlapLatency)
        let viewModel = viewModel(repository: repository)

        async let first: Void = viewModel.onSave()
        await Task.yield()
        await viewModel.onSave()
        await first

        #expect(await repository.addCount == 1)
    }

    @Test func hoursKeepOnlyDigitsUpToFiveCharacters() {
        let viewModel = viewModel(repository: FakeLibraryRepository(latency: .zero))

        viewModel.onHoursChange("12a34567")

        #expect(viewModel.hours == "12345")
    }

    @Test func hoursIgnoreNumberSymbolsThatAreNotPlainDigits() {
        let viewModel = viewModel(repository: FakeLibraryRepository(latency: .zero))

        viewModel.onHoursChange("1\u{00BD}2\u{0663}")

        #expect(viewModel.hours == "12")
    }
}
