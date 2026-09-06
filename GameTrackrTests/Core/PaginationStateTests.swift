import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct PaginationStateTests {
    private struct Item: Identifiable, Equatable {
        let id: Int
    }

    private func page(_ ids: [Int], current: Int, last: Int, total: Int? = nil) -> PaginatedResponse<Int> {
        PaginatedResponse(
            data: ids,
            currentPage: current,
            lastPage: last,
            perPage: 20,
            total: total ?? (last * 20)
        )
    }

    private func append(_ state: PaginationState<Item>, _ response: PaginatedResponse<Int>) {
        state.append(response: response) { $0.map(Item.init(id:)) }
    }

    @Test func startsReadyToLoadTheFirstPage() {
        let state = PaginationState<Item>()

        #expect(state.canLoadMore)
        #expect(state.currentPage == 0)
        #expect(state.lastPage == 1)
        #expect(state.items.isEmpty)
    }

    @Test func accumulatesPagesAndCopiesTheServerMeta() {
        let state = PaginationState<Item>()

        append(state, page([1, 2], current: 1, last: 3, total: 50))
        append(state, page([3, 4], current: 2, last: 3, total: 50))

        #expect(state.items.map(\.id) == [1, 2, 3, 4])
        #expect(state.currentPage == 2)
        #expect(state.lastPage == 3)
        #expect(state.total == 50)
        #expect(state.canLoadMore)
    }

    @Test func stopsOnceTheLastPageArrives() {
        let state = PaginationState<Item>()

        append(state, page([1], current: 3, last: 3))

        #expect(!state.canLoadMore)
    }

    @Test func refusesToLoadMoreWhileARequestIsInFlight() {
        let state = PaginationState<Item>()
        append(state, page([1], current: 1, last: 5))

        state.setLoading(true)
        #expect(!state.canLoadMore)

        state.setLoading(false)
        #expect(state.canLoadMore)
    }

    @Test func resetPutsTheStateBackToAPendingFirstPage() {
        let state = PaginationState<Item>()
        append(state, page([1, 2], current: 2, last: 4, total: 80))

        state.reset()

        #expect(state.items.isEmpty)
        #expect(state.currentPage == 0)
        #expect(state.lastPage == 1)
        #expect(state.total == 0)
        #expect(state.canLoadMore)
    }

    @Test func appendingAfterAResetDoesNotBringTheOldPageBack() {
        let state = PaginationState<Item>()
        append(state, page([1, 2], current: 1, last: 4))

        state.reset()
        append(state, page([9], current: 1, last: 1))

        #expect(state.items.map(\.id) == [9])
    }

    @Test func snapshotAndRestoreRoundTripTheWholeState() {
        let state = PaginationState<Item>()
        append(state, page([1, 2, 3], current: 2, last: 7, total: 140))
        let snapshot = state.snapshot

        let restored = PaginationState<Item>()
        restored.restore(snapshot)

        #expect(restored.items.map(\.id) == [1, 2, 3])
        #expect(restored.currentPage == 2)
        #expect(restored.lastPage == 7)
        #expect(restored.total == 140)
    }

    @Test func restoreReplacesWhateverWasThereBefore() {
        let state = PaginationState<Item>()
        append(state, page([1, 2], current: 1, last: 2))

        state.restore(PaginationSnapshot(items: [Item(id: 9)], currentPage: 1, lastPage: 1, total: 1))

        #expect(state.items.map(\.id) == [9])
        #expect(!state.canLoadMore)
    }

    @Test func updateItemIgnoresAnIndexThatIsNoLongerThere() {
        let state = PaginationState<Item>()
        append(state, page([1, 2], current: 1, last: 1))

        state.updateItem(at: 99, with: Item(id: 7))
        state.updateItem(at: -1, with: Item(id: 7))

        #expect(state.items.map(\.id) == [1, 2])

        state.updateItem(at: 1, with: Item(id: 7))
        #expect(state.items.map(\.id) == [1, 7])
    }

    @Test func insertsFindsAndRemovesByPredicate() {
        let state = PaginationState<Item>()
        append(state, page([1, 2, 3], current: 1, last: 1))

        state.insert(Item(id: 0), at: 0)
        #expect(state.items.map(\.id) == [0, 1, 2, 3])
        #expect(state.firstIndex { $0.id == 2 } == 2)
        #expect(state.firstIndex { $0.id == 42 } == nil)

        state.removeAll { $0.id.isMultiple(of: 2) }
        #expect(state.items.map(\.id) == [1, 3])
    }
}
