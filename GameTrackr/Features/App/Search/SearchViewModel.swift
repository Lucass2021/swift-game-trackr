import SwiftUI

@MainActor
@Observable
final class SearchViewModel {
    let pagination = PaginationState<Game>()
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private(set) var error: String?

    private let service = GameService.shared
    private var search: String?
    private var platform: GamePlatform?
    private var generation = 0

    var games: [Game] {
        pagination.items
    }

    var isLoadingMore: Bool {
        pagination.isLoadingMore
    }

    var total: Int {
        pagination.total
    }

    func applyFilters(search: String, platform: GamePlatform?) async {
        self.search = search.isEmpty ? nil : search
        self.platform = platform
        await load(reset: true)
    }

    func loadMore() async {
        await load(reset: false)
    }

    private func load(reset: Bool) async {
        if reset {
            generation += 1
            isLoading = true
            error = nil
            pagination.reset()
        } else {
            guard pagination.canLoadMore else { return }
        }
        pagination.setLoading(true)

        let requestGeneration = generation

        do {
            let response = try await service.fetchAllNewReleases(
                page: pagination.currentPage + 1,
                perPage: Self.perPage,
                search: search,
                platform: platform
            )
            guard requestGeneration == generation else { return }
            pagination.append(response: response) { $0.map(Game.init(dto:)) }
        } catch {
            guard requestGeneration == generation, !Task.isCancelled else { return }
            if reset { self.error = error.localizedDescription }
        }

        guard !Task.isCancelled else { return }

        if reset {
            isLoading = false
            hasLoaded = true
        }
        pagination.setLoading(false)
    }

    private static let perPage = 20
}
