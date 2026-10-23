import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct LibraryViewModelFavoriteTests {
    private static let userId = 7
    private static let overlapLatency: Duration = .milliseconds(50)
    private static let twinSlug = "cyberpunk-2077-phantom-liberty-2"
    private static let slug = LibraryMockData.entries[0].slug

    @Test func aFavoriteIsShownRightAwayAndSurvivesAReload() async {
        let repository = FakeLibraryRepository(latency: .zero)
        let viewModel = await loadedViewModel(repository)

        viewModel.onToggleFavorite(Self.slug)
        #expect(isFavorite(viewModel, Self.slug))
        await waitUntil { await repository.isFavorite(Self.slug) }
        await viewModel.load()

        #expect(isFavorite(viewModel, Self.slug))
    }

    @Test func aFailedFavoriteIsRevertedAndShowsAnError() async {
        let repository = FakeLibraryRepository(latency: .zero)
        let viewModel = await loadedViewModel(repository)

        await repository.setFailure(APIError.networkFailure)
        viewModel.onToggleFavorite(Self.slug)
        await waitUntil { viewModel.errorMessage != nil }

        #expect(!isFavorite(viewModel, Self.slug))
        #expect(viewModel.errorMessage != nil)
    }

    @Test func aFavoriteOnlyChangesTheGameWithThatSlugWhenTitlesRepeat() async {
        let original = LibraryMockData.entries[0]
        let twin = LibraryEntry(
            title: original.title,
            slug: Self.twinSlug,
            status: original.status,
            rating: original.rating,
            hours: original.hours,
            coverStart: original.coverStart,
            coverEnd: original.coverEnd
        )
        let repository = FakeLibraryRepository(entries: [original, twin], latency: .zero)
        let viewModel = await loadedViewModel(repository)

        viewModel.onToggleFavorite(Self.twinSlug)
        await waitUntil { await repository.isFavorite(Self.twinSlug) }

        #expect(isFavorite(viewModel, Self.twinSlug))
        #expect(!isFavorite(viewModel, original.slug))
    }

    @Test func aQuickSecondToggleSupersedesTheFirstWithoutAnError() async {
        let original = LibraryMockData.entries[0]
        let favorite = LibraryEntry(
            title: original.title,
            slug: original.slug,
            status: original.status,
            rating: original.rating,
            hours: original.hours,
            isFavorite: true,
            coverStart: original.coverStart,
            coverEnd: original.coverEnd
        )
        let repository = FakeLibraryRepository(entries: [favorite], latency: Self.overlapLatency)
        let viewModel = await loadedViewModel(repository)

        await repository.setFailure(APIError.networkFailure)
        viewModel.onToggleFavorite(Self.slug)
        await waitUntil { await repository.setFavoriteCount == 1 }
        await repository.setFailure(nil)
        viewModel.onToggleFavorite(Self.slug)
        await waitUntil { await repository.setFavoriteCount == 2 }
        try? await Task.sleep(for: Self.overlapLatency * 2)

        #expect(isFavorite(viewModel, Self.slug))
        #expect(await repository.isFavorite(Self.slug))
        #expect(viewModel.errorMessage == nil)
    }

    private func loadedViewModel(_ repository: FakeLibraryRepository) async -> LibraryViewModel {
        let viewModel = LibraryViewModel(repository: repository, libraryUpdates: LibraryUpdates())
        await viewModel.loadFor(Self.userId)
        return viewModel
    }

    private func isFavorite(_ viewModel: LibraryViewModel, _ slug: String) -> Bool {
        viewModel.entries.first { $0.slug == slug }?.isFavorite == true
    }

    private func waitUntil(_ condition: () async -> Bool) async {
        while await !condition() {
            await Task.yield()
        }
    }
}
