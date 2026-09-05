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

    private let service: GameServicing
    private let cache: FeedCache
    private var scope: SearchScope = .all
    private var platform: GamePlatform?
    private var generation = 0

    init(service: GameServicing = GameService.live, cache: FeedCache = FeedCache()) {
        self.service = service
        self.cache = cache
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
        platforms = await (try? service.fetchPlatforms()) ?? []
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

        do {
            let response = try await service.fetchFeed(
                scope,
                page: pagination.currentPage + 1,
                perPage: Self.perPage,
                search: appliedSearch.isEmpty ? nil : appliedSearch,
                platform: platform
            )
            guard requestGeneration == generation else { return }
            pagination.append(response: response) { $0.map(Game.init(dto:)) }
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

    private static let perPage = 20
}
