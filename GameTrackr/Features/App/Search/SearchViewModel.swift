import Foundation

@MainActor
@Observable
final class SearchViewModel {
    static let pageSize = 20
    static let searchDebounce: Duration = .milliseconds(300)

    let scope: SearchScope
    private(set) var query = ""
    private(set) var platformSlug: String?
    private(set) var platforms: [GamePlatform] = []
    private(set) var games: [Game] = []
    private(set) var currentPage = 0
    private(set) var lastPage = 1
    private(set) var total = 0
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var isSearchPending = false
    private(set) var hasError = false
    private(set) var loadMoreFailed = false

    var isWaiting: Bool {
        games.isEmpty && !hasError && (currentPage == 0 || isLoading || isSearchPending)
    }

    var isEmpty: Bool {
        currentPage > 0 && games.isEmpty && !hasError && !isLoading && !isSearchPending
    }

    var isSearching: Bool {
        !query.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var canLoadMore: Bool {
        (1 ..< lastPage).contains(currentPage) && !isLoading && !isLoadingMore && !isSearchPending && !loadMoreFailed
    }

    private let repository: GameRepository
    private let cache = FeedCache()
    private let searchDebounce: Duration
    private var pageTask: Task<Void, Never>?
    private var searchTask: Task<Void, Never>?
    private var appliedKey: FeedKey

    init(scope: SearchScope, repository: GameRepository, searchDebounce: Duration = SearchViewModel.searchDebounce) {
        self.scope = scope
        self.repository = repository
        self.searchDebounce = searchDebounce
        appliedKey = FeedKey(scope: scope, search: nil, platform: nil)
    }

    func loadIfNeeded() async {
        async let platformsLoad: Void = loadPlatformsIfNeeded()
        if currentPage == 0, !isLoading {
            await load()
        }
        await platformsLoad
    }

    func load() async {
        searchTask?.cancel()
        isSearchPending = false
        await applyFilters()
    }

    func loadMore() async {
        guard currentPage > 0, currentPage < lastPage, !isLoading, !isLoadingMore, !isSearchPending else { return }
        await loadPage(currentPage + 1)
    }

    @discardableResult
    func onQueryChange(_ query: String) -> Task<Void, Never> {
        self.query = query
        isSearchPending = true
        searchTask?.cancel()
        let task = Task { [searchDebounce] in
            try? await Task.sleep(for: searchDebounce)
            guard !Task.isCancelled else { return }
            isSearchPending = false
            guard currentKey != appliedKey || hasError else { return }
            await applyFilters()
        }
        searchTask = task
        return task
    }

    func onPlatformChange(_ platformSlug: String?) async {
        guard platformSlug != self.platformSlug else { return }
        self.platformSlug = platformSlug
        await load()
    }

    func onClearFilters() async {
        query = ""
        platformSlug = nil
        await load()
    }

    private func loadPlatformsIfNeeded() async {
        guard platforms.isEmpty else { return }
        platforms = await (try? repository.fetchPlatforms()) ?? []
    }

    private var currentKey: FeedKey {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        return FeedKey(
            scope: scope,
            search: trimmed.isEmpty ? nil : trimmed,
            platform: platforms.first { $0.slug == platformSlug }
        )
    }

    private func applyFilters() async {
        appliedKey = currentKey
        guard let cached = cache.snapshot(for: appliedKey) else {
            await loadPage(1)
            return
        }
        pageTask?.cancel()
        apply(cached)
        isLoading = false
        isLoadingMore = false
        hasError = false
        loadMoreFailed = false
    }

    private func loadPage(_ page: Int) async {
        pageTask?.cancel()
        if page == 1 {
            apply(PaginationSnapshot(items: [], currentPage: 0, lastPage: 1, total: 0))
            isLoading = true
            isLoadingMore = false
        } else {
            isLoadingMore = true
        }
        hasError = false
        loadMoreFailed = false
        let key = appliedKey
        let task = Task { await fetchPage(page, key: key) }
        pageTask = task
        await task.value
    }

    private func fetchPage(_ page: Int, key: FeedKey) async {
        do {
            let result = try await fetch(page, key: key)
            guard !Task.isCancelled else { return }
            let items = page == 1 ? result.items : games + result.items
            let snapshot = PaginationSnapshot(
                items: items,
                currentPage: result.currentPage,
                lastPage: result.lastPage,
                total: result.total
            )
            apply(snapshot)
            cache.store(snapshot, for: key)
        } catch {
            guard !Task.isCancelled else { return }
            hasError = page == 1
            loadMoreFailed = page > 1
        }
        isLoading = false
        isLoadingMore = false
    }

    private func fetch(_ page: Int, key: FeedKey) async throws -> Page<Game> {
        let platformSlug = key.platform?.slug
        switch key.scope {
        case .mostAnticipated:
            return try await repository.fetchAllMostAnticipated(
                page: page, perPage: Self.pageSize, search: key.search, platformSlug: platformSlug
            )
        case .newReleases:
            return try await repository.fetchAllNewReleases(
                page: page, perPage: Self.pageSize, search: key.search, platformSlug: platformSlug
            )
        case .all:
            return try await repository.searchGames(
                page: page, perPage: Self.pageSize, search: key.search, platformSlug: platformSlug
            )
        }
    }

    private func apply(_ snapshot: PaginationSnapshot<Game>) {
        games = snapshot.items
        currentPage = snapshot.currentPage
        lastPage = snapshot.lastPage
        total = snapshot.total
    }
}
