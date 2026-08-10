import SwiftUI

@MainActor
@Observable
final class PaginationState<Item: Identifiable> {
    private(set) var items: [Item] = []
    private(set) var isLoadingMore = false
    private(set) var currentPage = 0
    private(set) var lastPage = 1

    var canLoadMore: Bool {
        currentPage < lastPage && !isLoadingMore
    }

    func reset() {
        items = []
        currentPage = 0
        lastPage = 1
    }

    func append<D: Decodable>(response: PaginatedResponse<D>, transform: ([D]) -> [Item]) {
        items.append(contentsOf: transform(response.data))
        currentPage = response.currentPage
        lastPage = response.lastPage
    }

    func setLoading(_ value: Bool) {
        isLoadingMore = value
    }

    func insert(_ item: Item, at index: Int) {
        items.insert(item, at: index)
    }

    func updateItem(at index: Int, with item: Item) {
        guard items.indices.contains(index) else { return }
        items[index] = item
    }

    func firstIndex(where predicate: (Item) -> Bool) -> Int? {
        items.firstIndex(where: predicate)
    }

    func removeAll(where predicate: (Item) -> Bool) {
        items.removeAll(where: predicate)
    }
}
