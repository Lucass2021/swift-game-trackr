import SwiftUI

@MainActor
@Observable
final class HomeFeed {
    private(set) var games: [Game] = []
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private(set) var failed = false

    var isEmptyAndSettled: Bool {
        games.isEmpty && hasLoaded && !isLoading
    }

    fileprivate func load(force: Bool, _ fetch: () async throws -> [GameDTO]) async {
        guard !isLoading, force || !hasLoaded || games.isEmpty else { return }
        isLoading = true
        failed = false

        do {
            games = try await fetch().map(Game.init(dto:))
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

    private let service = GameService.shared

    func loadAll(force: Bool = false) async {
        async let releases: Void = newReleases.load(force: force) {
            try await service.fetchSlider(.newReleases)
        }
        async let anticipated: Void = mostAnticipated.load(force: force) {
            try await service.fetchSlider(.mostAnticipated)
        }
        _ = await (releases, anticipated)
    }
}
