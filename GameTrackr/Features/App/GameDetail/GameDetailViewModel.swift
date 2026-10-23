import Foundation

@MainActor
@Observable
final class GameDetailViewModel {
    private(set) var game: GameDetail?
    private(set) var isLoading = false
    private(set) var hasError = false

    private let repository: GameRepository
    private let slug: String
    private var loadTask: Task<Void, Never>?

    init(slug: String, repository: GameRepository) {
        self.slug = slug
        self.repository = repository
    }

    func loadIfNeeded() async {
        guard game == nil, !isLoading else { return }
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
            let result = try await repository.fetchGame(slug: slug)
            guard !Task.isCancelled else { return }
            game = result
        } catch {
            guard !Task.isCancelled else { return }
            hasError = true
        }
        isLoading = false
    }
}
