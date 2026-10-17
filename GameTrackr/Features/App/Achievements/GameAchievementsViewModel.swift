import Foundation

@MainActor
@Observable
final class GameAchievementsViewModel {
    private(set) var game: GameAchievements?
    private(set) var isLoading = false
    private(set) var hasError = false

    var unlockedAchievements: [Achievement] {
        game?.achievements.filter(\.isUnlocked) ?? []
    }

    var lockedAchievements: [Achievement] {
        game?.achievements.filter { !$0.isUnlocked } ?? []
    }

    private let gameId: Int
    private let repository: AchievementsRepository
    private var loadTask: Task<Void, Never>?

    init(gameId: Int, repository: AchievementsRepository) {
        self.gameId = gameId
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
            let result = try await repository.fetchGameAchievements(id: gameId)
            guard !Task.isCancelled else { return }
            game = result
        } catch {
            guard !Task.isCancelled else { return }
            hasError = true
        }
        isLoading = false
    }
}
