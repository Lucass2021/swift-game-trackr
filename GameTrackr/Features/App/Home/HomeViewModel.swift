import SwiftUI

@MainActor
@Observable
final class HomeFeed {
    private(set) var games: [Game] = []
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private(set) var failed = false

    fileprivate func load(force: Bool, _ fetch: () async throws -> [Game]) async {
        guard !isLoading, force || !hasLoaded || games.isEmpty else { return }
        isLoading = true
        failed = false

        do {
            games = try await fetch()
        } catch {
            failed = true
        }

        isLoading = false
        hasLoaded = true
    }
}

@MainActor
@Observable
final class HomeViewModel {
    let newReleases = HomeFeed()
    let mostAnticipated = HomeFeed()

    private static let sliderLimit = 10

    private let repository: GameRepository

    init(repository: GameRepository = RemoteGameRepository()) {
        self.repository = repository
    }

    func loadAll(force: Bool = false) async {
        async let releases: Void = newReleases.load(force: force) {
            try await repository.fetchNewReleases(limit: Self.sliderLimit)
        }
        async let anticipated: Void = mostAnticipated.load(force: force) {
            try await repository.fetchMostAnticipated(limit: Self.sliderLimit)
        }
        _ = await (releases, anticipated)
    }
}
