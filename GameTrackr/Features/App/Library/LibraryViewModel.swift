import Foundation

@MainActor
@Observable
final class LibraryViewModel {
    static let pageSize = 3

    private(set) var entries: [LibraryEntry] = []
    private(set) var stats: LibraryStats?
    private(set) var filter: LibraryStatus?
    private(set) var currentPage = 0
    private(set) var lastPage = 1
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var hasError = false
    private(set) var loadMoreFailed = false
    var errorMessage: String?

    var canLoadMore: Bool {
        (1 ..< lastPage).contains(currentPage) && !isLoading && !isLoadingMore && !loadMoreFailed
    }

    var isLibraryEmpty: Bool {
        currentPage > 0 && entries.isEmpty && (filter == nil || stats?.totalGames == 0)
    }

    private let repository: LibraryRepository
    private var listTask: Task<Void, Never>?
    private var statsTask: Task<Void, Never>?
    private var favoriteTasks: [String: Task<Void, Never>] = [:]
    private var loadedUserId: Int?
    private(set) var updateTask: Task<Void, Never>?

    init(repository: LibraryRepository, libraryUpdates: LibraryUpdates) {
        self.repository = repository
        libraryUpdates.observe(self) { [weak self] _ in
            self?.onGameAdded()
        }
    }

    func loadFor(_ userId: Int?) async {
        guard userId != loadedUserId else { return }
        loadedUserId = userId
        clear()
        guard userId != nil else { return }
        await load()
    }

    func load() async {
        if stats == nil { loadStats() }
        await loadPage(1)
    }

    func loadMore() async {
        guard currentPage > 0, currentPage < lastPage, !isLoading, !isLoadingMore else { return }
        await loadPage(currentPage + 1)
    }

    func onFilterChange(_ status: LibraryStatus?) async {
        guard status != filter else { return }
        filter = status
        guard loadedUserId != nil else { return }
        await loadPage(1)
    }

    func onToggleFavorite(_ slug: String) {
        guard let entry = entries.first(where: { $0.slug == slug }) else { return }
        let isFavorite = !entry.isFavorite
        setFavoriteLocally(slug, isFavorite)
        favoriteTasks[slug]?.cancel()
        favoriteTasks[slug] = Task {
            do {
                try await repository.setFavorite(slug: slug, isFavorite: isFavorite)
            } catch {
                guard !Task.isCancelled else { return }
                setFavoriteLocally(slug, !isFavorite)
                errorMessage = "Couldn't update favorites. Please try again."
            }
        }
    }

    private func loadPage(_ page: Int) async {
        listTask?.cancel()
        if page == 1 {
            entries = []
            currentPage = 0
            lastPage = 1
            isLoading = true
            isLoadingMore = false
        } else {
            isLoadingMore = true
        }
        hasError = false
        loadMoreFailed = false
        let task = Task { await fetch(page: page, filter: filter) }
        listTask = task
        await task.value
    }

    private func fetch(page: Int, filter: LibraryStatus?) async {
        do {
            let result = try await repository.fetchLibrary(status: filter, page: page, perPage: Self.pageSize)
            guard !Task.isCancelled else { return }
            entries = page == 1 ? result.items : entries + result.items
            currentPage = result.currentPage
            lastPage = result.lastPage
        } catch {
            guard !Task.isCancelled else { return }
            hasError = page == 1
            loadMoreFailed = page > 1
        }
        isLoading = false
        isLoadingMore = false
    }

    private func onGameAdded() {
        guard loadedUserId != nil else { return }
        loadStats()
        updateTask = Task { await loadPage(1) }
    }

    private func loadStats() {
        statsTask?.cancel()
        statsTask = Task {
            guard let result = try? await repository.fetchLibraryStats(), !Task.isCancelled else { return }
            stats = result
        }
    }

    private func setFavoriteLocally(_ slug: String, _ isFavorite: Bool) {
        guard let index = entries.firstIndex(where: { $0.slug == slug }) else { return }
        entries[index].isFavorite = isFavorite
    }

    private func clear() {
        listTask?.cancel()
        listTask = nil
        statsTask?.cancel()
        statsTask = nil
        favoriteTasks.values.forEach { $0.cancel() }
        favoriteTasks = [:]
        entries = []
        stats = nil
        filter = nil
        currentPage = 0
        lastPage = 1
        isLoading = false
        isLoadingMore = false
        hasError = false
        loadMoreFailed = false
        errorMessage = nil
    }
}
