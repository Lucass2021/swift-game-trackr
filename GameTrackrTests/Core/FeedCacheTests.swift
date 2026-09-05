import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct FeedCacheTests {
    private let key = FeedKey(scope: .all, search: nil, platform: nil)
    private let snapshot = PaginationSnapshot<Game>(items: [], currentPage: 2, lastPage: 5, total: 100)

    @Test func returnsTheSnapshotWhileTheEntryIsFresh() {
        var now = Date(timeIntervalSince1970: 0)
        let cache = FeedCache { now }

        cache.store(snapshot, for: key)
        now = now.addingTimeInterval(4 * 60)

        #expect(cache.snapshot(for: key)?.currentPage == 2)
    }

    @Test func dropsTheEntryOnceTheFiveMinuteTTLPasses() {
        var now = Date(timeIntervalSince1970: 0)
        let cache = FeedCache { now }

        cache.store(snapshot, for: key)
        now = now.addingTimeInterval(5 * 60 + 1)

        #expect(cache.snapshot(for: key) == nil)
    }

    @Test func keysEntriesByScopeSearchAndPlatform() {
        let cache = FeedCache()
        cache.store(snapshot, for: key)

        let otherSearch = FeedKey(scope: .all, search: "elden", platform: nil)
        let otherScope = FeedKey(scope: .newReleases, search: nil, platform: nil)

        #expect(cache.snapshot(for: key) != nil)
        #expect(cache.snapshot(for: otherSearch) == nil)
        #expect(cache.snapshot(for: otherScope) == nil)
    }

    @Test func invalidateClearsEverything() {
        let cache = FeedCache()
        cache.store(snapshot, for: key)

        cache.invalidate()

        #expect(cache.snapshot(for: key) == nil)
    }
}
