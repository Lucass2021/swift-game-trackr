import Foundation

@MainActor
@Observable
final class AchievementsViewModel {
    static let pageSize = 3

    private(set) var games: [GameAchievements] = []
    private(set) var summary: AchievementsSummary?
    private(set) var filter: AchievementFilter = .all
    private(set) var currentPage = 0
    private(set) var lastPage = 1
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var hasError = false
    private(set) var loadMoreFailed = false

    var canLoadMore: Bool {
        (1 ..< lastPage).contains(currentPage) && !isLoading && !isLoadingMore && !loadMoreFailed
    }

    var showsSummary: Bool {
        summary != nil && filter == .all
    }

    private let repository: AchievementsRepository
    private var listTask: Task<Void, Never>?
    private var summaryTask: Task<Void, Never>?

    init(repository: AchievementsRepository) {
        self.repository = repository
    }

    func loadIfNeeded() async {
        guard currentPage == 0, !isLoading else { return }
        await load()
    }

    func load() async {
        if summary == nil { loadSummary() }
        await loadPage(1)
    }

    func loadMore() async {
        guard currentPage > 0, currentPage < lastPage, !isLoading, !isLoadingMore else { return }
        await loadPage(currentPage + 1)
    }

    func onFilterChange(_ filter: AchievementFilter) async {
        guard filter != self.filter else { return }
        self.filter = filter
        await loadPage(1)
    }

    private func loadPage(_ page: Int) async {
        listTask?.cancel()
        if page == 1 {
            games = []
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

    private func fetch(page: Int, filter: AchievementFilter) async {
        do {
            let result = try await repository.fetchAchievementGames(
                filter: filter,
                page: page,
                perPage: Self.pageSize
            )
            guard !Task.isCancelled else { return }
            games = page == 1 ? result.items : games + result.items
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

    private func loadSummary() {
        summaryTask?.cancel()
        summaryTask = Task {
            guard let result = try? await repository.fetchAchievementsSummary(), !Task.isCancelled else { return }
            summary = result
        }
    }
}
