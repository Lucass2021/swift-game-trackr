import Foundation

enum HomeSection: CaseIterable {
    case newReleases
    case mostAnticipated
}

struct HomeFeed {
    var games: [Game] = []
    var isLoading = false
    var hasLoaded = false
    var hasError = false

    var isWaiting: Bool {
        games.isEmpty && (isLoading || !hasLoaded)
    }
}

@MainActor
@Observable
final class HomeViewModel {
    private static let sliderLimit = 10

    private(set) var newReleases = HomeFeed()
    private(set) var mostAnticipated = HomeFeed()
    private(set) var isRefreshing = false
    var toastMessage: String?

    private let repository: GameRepository
    private var loads: [HomeSection: Task<Bool, Never>] = [:]

    init(repository: GameRepository) {
        self.repository = repository
    }

    func feed(_ section: HomeSection) -> HomeFeed {
        switch section {
        case .newReleases: newReleases
        case .mostAnticipated: mostAnticipated
        }
    }

    func loadIfNeeded() async {
        let pending = HomeSection.allCases.filter { !feed($0).hasLoaded && loads[$0] == nil }.map(startLoad)
        for load in pending {
            _ = await load.value
        }
    }

    func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        let sectionLoads = HomeSection.allCases.map { loads[$0] ?? startLoad($0) }
        var failed = false
        for load in sectionLoads where await !(load.value) {
            failed = true
        }
        let hasGames = HomeSection.allCases.contains { !feed($0).games.isEmpty }
        if failed, hasGames {
            toastMessage = "Couldn't refresh. Please try again."
        }
    }

    func onRetry(_ section: HomeSection) async {
        guard loads[section] == nil else { return }
        _ = await startLoad(section).value
    }

    private func startLoad(_ section: HomeSection) -> Task<Bool, Never> {
        update(section) {
            $0.isLoading = true
            $0.hasError = false
        }
        let load = Task {
            let succeeded = await self.load(section)
            self.loads[section] = nil
            return succeeded
        }
        loads[section] = load
        return load
    }

    private func load(_ section: HomeSection) async -> Bool {
        do {
            let games = try await fetch(section)
            update(section) { $0.games = games }
            finish(section)
            return true
        } catch {
            update(section) { $0.hasError = true }
            finish(section)
            return false
        }
    }

    private func fetch(_ section: HomeSection) async throws -> [Game] {
        switch section {
        case .newReleases: try await repository.fetchNewReleases(limit: Self.sliderLimit)
        case .mostAnticipated: try await repository.fetchMostAnticipated(limit: Self.sliderLimit)
        }
    }

    private func finish(_ section: HomeSection) {
        update(section) {
            $0.isLoading = false
            $0.hasLoaded = true
        }
    }

    private func update(_ section: HomeSection, _ change: (inout HomeFeed) -> Void) {
        switch section {
        case .newReleases: change(&newReleases)
        case .mostAnticipated: change(&mostAnticipated)
        }
    }
}
