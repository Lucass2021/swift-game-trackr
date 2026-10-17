import Foundation

@MainActor
@Observable
final class ProfileViewModel {
    private(set) var overview: ProfileOverview?
    private(set) var isLoading = false
    private(set) var hasError = false

    private let repository: ProfileOverviewRepository
    private var loadTask: Task<Void, Never>?
    private var loadedUserId: Int?

    init(repository: ProfileOverviewRepository) {
        self.repository = repository
    }

    func loadFor(_ userId: Int?) async {
        guard userId != loadedUserId else { return }
        loadedUserId = userId
        loadTask?.cancel()
        loadTask = nil
        overview = nil
        isLoading = false
        hasError = false
        guard userId != nil else { return }
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
            let result = try await repository.fetchMyOverview()
            guard !Task.isCancelled else { return }
            overview = result
        } catch {
            guard !Task.isCancelled else { return }
            hasError = true
        }
        isLoading = false
    }
}
