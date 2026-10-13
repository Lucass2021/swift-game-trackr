import SwiftUI

@MainActor
@Observable
final class SearchViewModel {
    let pagination = PaginationState<Game>()
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private(set) var error: String?
    private(set) var appliedSearch = ""
    private(set) var platforms: [GamePlatform] = []

    private let cache = FeedCache()
    private var scope: SearchScope = .all
    private var platform: GamePlatform?
    private var generation = 0

    private let repository: GameRepository

    init(repository: GameRepository = RemoteGameRepository()) {
        self.repository = repository
    }

    var games: [Game] {
        pagination.items
    }

    var isLoadingMore: Bool {
        pagination.isLoadingMore
    }

    var total: Int {
        pagination.total
    }

    func loadPlatforms() async {
        guard platforms.isEmpty else { return }
        platforms = await (try? repository.fetchPlatforms()) ?? []
    }

    func applyFilters(scope: SearchScope, search: String, platform: GamePlatform?) async {
        self.scope = scope
        appliedSearch = search
        self.platform = platform
        generation += 1

        if let cached = cache.snapshot(for: key) {
            pagination.restore(cached)
            pagination.setLoading(false)
            isLoading = false
            hasLoaded = true
            error = nil
            return
        }

        await load(reset: true)
    }

    func loadMore() async {
        await load(reset: false)
    }

    private var key: FeedKey {
        FeedKey(scope: scope, search: appliedSearch.isEmpty ? nil : appliedSearch, platform: platform)
    }

    private func load(reset: Bool) async {
        if reset {
            isLoading = true
            error = nil
            pagination.reset()
        } else {
            guard pagination.canLoadMore else { return }
        }
        pagination.setLoading(true)

        let requestGeneration = generation

        let nextPage = pagination.currentPage + 1
        let search = appliedSearch.isEmpty ? nil : appliedSearch
        let platformSlug = platform?.slug
        do {
            let page = try await fetchPage(nextPage, search: search, platformSlug: platformSlug)
            guard requestGeneration == generation else { return }
            pagination.append(page: page)
            cache.store(pagination.snapshot, for: key)
        } catch {
            guard requestGeneration == generation, !Task.isCancelled else { return }
            if reset { self.error = error.localizedDescription }
        }

        guard !Task.isCancelled else { return }

        if reset {
            isLoading = false
            hasLoaded = true
        }
        pagination.setLoading(false)
    }

    private func fetchPage(_ page: Int, search: String?, platformSlug: String?) async throws -> Page<Game> {
        switch scope {
        case .mostAnticipated:
            try await repository.fetchAllMostAnticipated(
                page: page, perPage: Self.perPage, search: search, platformSlug: platformSlug
            )
        case .newReleases:
            try await repository.fetchAllNewReleases(
                page: page, perPage: Self.perPage, search: search, platformSlug: platformSlug
            )
        case .all:
            try await repository.searchGames(
                page: page,
                perPage: Self.perPage,
                search: search,
                platformSlug: platformSlug
            )
        }
    }

    private static let perPage = 20
}
