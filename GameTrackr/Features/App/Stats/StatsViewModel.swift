import Foundation

@MainActor
@Observable
final class StatsViewModel {
    private(set) var stats: UserStats?
    private(set) var isLoading = false
    private(set) var hasError = false

    private let repository: StatsRepository
    private var loadTask: Task<Void, Never>?

    init(repository: StatsRepository) {
        self.repository = repository
    }

    func loadIfNeeded() async {
        guard stats == nil, !isLoading else { return }
        await load()
    }

    func load() async {
        loadTask?.cancel()
        isLoading = true
        hasError = false
        let task = Task { await fetch() }
        loadTask = task
        await task.value
    }

    private func fetch() async {
        do {
            let result = try await repository.fetchStats()
            guard !Task.isCancelled else { return }
            stats = result
        } catch {
            guard !Task.isCancelled else { return }
            hasError = true
        }
        isLoading = false
    }
}
