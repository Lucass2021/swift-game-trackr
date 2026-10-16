actor FakeAchievementsRepository: AchievementsRepository {
    private(set) var fetchCount = 0
    private let games: [GameAchievements]
    private var failure: Error?
    private let latency: Duration

    init(
        games: [GameAchievements] = AchievementsMockData.games,
        failure: Error? = nil,
        latency: Duration = FakeLatency.responseDelay
    ) {
        self.games = games
        self.failure = failure
        self.latency = latency
    }

    func fetchAchievementGames(
        filter: AchievementFilter,
        page: Int,
        perPage: Int
    ) async throws -> Page<GameAchievements> {
        fetchCount += 1
        try await respond()
        return fakePage(items: games.filter { matches($0, filter) }, page: page, perPage: perPage)
    }

    func fetchAchievementsSummary() async throws -> AchievementsSummary {
        try await respond()
        return AchievementsSummary(
            unlockedCount: games.reduce(0) { $0 + $1.unlockedCount },
            total: games.reduce(0) { $0 + $1.total },
            platinumCount: games.count(where: \.hasPlatinum),
            completedCount: games.count(where: \.isComplete),
            gameCount: games.count
        )
    }

    func fetchGameAchievements(id: Int) async throws -> GameAchievements {
        try await respond()
        guard let game = games.first(where: { $0.id == id }) else { throw APIError.notFound }
        return game
    }

    func setFailure(_ error: Error?) {
        failure = error
    }

    private func matches(_ game: GameAchievements, _ filter: AchievementFilter) -> Bool {
        switch filter {
        case .all: true
        case .inProgress: !game.isComplete && game.unlockedCount > 0
        case .completed: game.isComplete
        }
    }

    private func respond() async throws {
        let error = failure
        try await Task.sleep(for: latency)
        if let error { throw error }
    }
}
