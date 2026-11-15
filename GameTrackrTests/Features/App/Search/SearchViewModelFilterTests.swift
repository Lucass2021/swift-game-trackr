import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct SearchViewModelFilterTests {
    private static let searchDebounce: Duration = .seconds(1)
    private static let slowLatency: Duration = .milliseconds(300)
    private static let manyGames = (0 ..< SearchViewModel.pageSize + 5).map { offset in
        Game(id: 100 + offset, name: "Game \(offset)", slug: "game-\(offset)")
    }

    private static func viewModel(
        _ repository: FakeGameRepository,
        debounce: Duration = .zero
    ) -> SearchViewModel {
        SearchViewModel(scope: .all, repository: repository, searchDebounce: debounce)
    }

    @Test func typingASearchAsksTheRepositoryOnceAfterThePause() async {
        let repository = FakeGameRepository(searchResults: Self.manyGames, latency: .zero)
        let viewModel = Self.viewModel(repository, debounce: Self.searchDebounce)
        await viewModel.loadIfNeeded()

        let keystrokes = ["z", "ze", "zelda"].map { viewModel.onQueryChange($0) }
        for keystroke in keystrokes {
            await keystroke.value
        }

        #expect(await repository.searchCount == 2)
        #expect(await repository.lastSearch == "zelda")
    }

    @Test func aKeystrokeThatKeepsTheSameFilterDoesNotSearchAgain() async {
        let repository = FakeGameRepository(searchResults: Self.manyGames, latency: Self.slowLatency)
        let viewModel = Self.viewModel(repository)

        let loading = Task { await viewModel.loadIfNeeded() }
        while await repository.searchCount == 0 {
            await Task.yield()
        }
        await viewModel.onQueryChange(" ").value
        await loading.value

        #expect(await repository.searchCount == 1)
        #expect(viewModel.games.count == SearchViewModel.pageSize)
        #expect(!viewModel.isSearchPending)
    }

    @Test func aLoadMoreWhileASearchIsPendingIsIgnored() async {
        let repository = FakeGameRepository(searchResults: Self.manyGames, latency: .zero)
        let viewModel = Self.viewModel(repository, debounce: Self.searchDebounce)
        await viewModel.loadIfNeeded()

        let search = viewModel.onQueryChange("zelda")
        await viewModel.loadMore()

        #expect(await repository.searchCount == 1)
        search.cancel()
    }

    @Test func aPlatformAsksTheRepositoryWithItsSlugAndClearingResetsTheFilters() async throws {
        let repository = FakeGameRepository(searchResults: Self.manyGames, latency: .zero)
        let viewModel = Self.viewModel(repository)
        await viewModel.loadIfNeeded()
        let platform = try #require(HomeMockData.platforms.first)

        await viewModel.onPlatformChange(platform.slug)

        #expect(await repository.lastPlatformSlug == platform.slug)

        await viewModel.onQueryChange("zelda").value
        await viewModel.onClearFilters()

        #expect(viewModel.query.isEmpty)
        #expect(viewModel.platformSlug == nil)
        #expect(viewModel.total == Self.manyGames.count)
        #expect(viewModel.games.count == SearchViewModel.pageSize)
    }

    @Test func aFilterLoadedBeforeComesFromTheCache() async throws {
        let repository = FakeGameRepository(searchResults: Self.manyGames, latency: .zero)
        let viewModel = Self.viewModel(repository)
        await viewModel.loadIfNeeded()
        let platform = try #require(HomeMockData.platforms.first)
        await viewModel.onPlatformChange(platform.slug)

        await viewModel.onPlatformChange(nil)

        #expect(await repository.searchCount == 2)
        #expect(viewModel.games.count == SearchViewModel.pageSize)
    }

    @Test func anOlderPageDoesNotReplaceANewerFilter() async throws {
        let repository = FakeGameRepository(searchResults: Self.manyGames, latency: Self.slowLatency)
        let viewModel = Self.viewModel(repository)
        let platform = try #require(HomeMockData.platforms.first)
        await viewModel.loadIfNeeded()

        let search = viewModel.onQueryChange("zelda")
        while await repository.searchCount < 2 {
            await Task.yield()
        }
        let filtering = Task { await viewModel.onPlatformChange(platform.slug) }
        while await repository.searchCount < 3 {
            await Task.yield()
        }
        await search.value

        #expect(viewModel.games.isEmpty)
        #expect(viewModel.isLoading)
        #expect(await repository.lastPlatformSlug == platform.slug)

        await filtering.value
    }
}
