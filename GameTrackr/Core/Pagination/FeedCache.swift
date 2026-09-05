import Foundation

struct FeedKey: Hashable {
    let scope: SearchScope
    let search: String?
    let platform: GamePlatform?
}

@MainActor
final class FeedCache {
    private var entries: [FeedKey: (snapshot: PaginationSnapshot<Game>, storedAt: Date)] = [:]
    private let now: @Sendable () -> Date

    nonisolated init(now: @escaping @Sendable () -> Date = Date.init) {
        self.now = now
    }

    func snapshot(for key: FeedKey) -> PaginationSnapshot<Game>? {
        guard let entry = entries[key] else { return nil }
        guard now().timeIntervalSince(entry.storedAt) < Self.timeToLive else {
            entries[key] = nil
            return nil
        }
        return entry.snapshot
    }

    func store(_ snapshot: PaginationSnapshot<Game>, for key: FeedKey) {
        entries[key] = (snapshot, now())
    }

    func invalidate() {
        entries.removeAll()
    }

    private static let timeToLive: TimeInterval = 5 * 60
}
