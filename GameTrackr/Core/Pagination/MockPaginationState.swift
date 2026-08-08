import SwiftUI

@MainActor
@Observable
final class MockPaginationState<Item: Identifiable> {
    private let allItems: [Item]
    private let pageSize: Int
    private(set) var items: [Item] = []
    private(set) var isLoadingMore = false

    var canLoadMore: Bool {
        items.count < allItems.count && !isLoadingMore
    }

    init(allItems: [Item], pageSize: Int = 6) {
        self.allItems = allItems
        self.pageSize = pageSize
        let end = min(pageSize, allItems.count)
        items = Array(allItems.prefix(end))
    }

    func loadNextPage() async {
        guard canLoadMore else { return }
        isLoadingMore = true
        try? await Task.sleep(for: .milliseconds(600))
        let start = items.count
        let end = min(start + pageSize, allItems.count)
        items.append(contentsOf: allItems[start ..< end])
        isLoadingMore = false
    }

    func reset() async {
        items = []
        await loadNextPage()
    }
}
