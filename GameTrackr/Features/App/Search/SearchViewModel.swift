import SwiftUI

@MainActor
@Observable
final class SearchViewModel {
    let pagination = PaginationState<Game>()
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private(set) var error: String?
    private(set) var filterFetches = 0

    private let service = GameService.shared

    var games: [Game] {
        pagination.items
    }

    var isLoadingMore: Bool {
        pagination.isLoadingMore
    }

    var canFetchMoreForFilter: Bool {
        pagination.canLoadMore && filterFetches < Self.filterFetchBudget
    }

    func resetFilterBudget() {
        filterFetches = 0
    }

    func loadNewReleases(reset: Bool = true) async {
        if reset {
            guard !isLoading else { return }
            isLoading = true
            error = nil
            pagination.reset()
            pagination.setLoading(true)
        } else {
            guard pagination.canLoadMore else { return }
            pagination.setLoading(true)
        }

        do {
            let response = try await service.fetchAllNewReleases(page: pagination.currentPage + 1, perPage: 20)
            pagination.append(response: response) { $0.map(Game.init(dto:)) }
        } catch {
            if reset { self.error = error.localizedDescription }
        }

        if reset {
            isLoading = false
            hasLoaded = true
        }
        pagination.setLoading(false)
    }

    func loadMoreNewReleases() async {
        await loadNewReleases(reset: false)
    }

    func loadMoreForFilter() async {
        filterFetches += 1
        await loadMoreNewReleases()
    }

    private static let filterFetchBudget = 5
}
