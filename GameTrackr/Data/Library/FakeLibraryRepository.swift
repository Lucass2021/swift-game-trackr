actor FakeLibraryRepository: LibraryRepository {
    private(set) var fetchCount = 0
    private(set) var setFavoriteCount = 0
    private(set) var addCount = 0
    private var entries: [LibraryEntry]
    private let stats: LibraryStats
    private var failure: Error?
    private let latency: Duration

    init(
        entries: [LibraryEntry] = LibraryMockData.entries,
        stats: LibraryStats = LibraryMockData.stats,
        failure: Error? = nil,
        latency: Duration = FakeLatency.responseDelay
    ) {
        self.entries = entries
        self.stats = stats
        self.failure = failure
        self.latency = latency
    }

    func fetchLibrary(status: LibraryStatus?, page: Int, perPage: Int) async throws -> Page<LibraryEntry> {
        fetchCount += 1
        try await respond()
        let filtered = status.map { status in entries.filter { $0.status == status } } ?? entries
        return fakePage(items: filtered, page: page, perPage: perPage)
    }

    func fetchLibraryStats() async throws -> LibraryStats {
        try await respond()
        return stats
    }

    func setFavorite(slug: String, isFavorite: Bool) async throws {
        setFavoriteCount += 1
        try await respond()
        guard let index = entries.firstIndex(where: { $0.slug == slug }) else { throw APIError.notFound }
        entries[index].isFavorite = isFavorite
    }

    func addToLibrary(_ entry: NewLibraryEntry) async throws {
        addCount += 1
        try await respond()
        var added = await MainActor.run {
            LibraryEntry(
                title: entry.title,
                slug: entry.slug,
                status: entry.status,
                rating: entry.rating,
                hours: entry.hours ?? 0,
                coverStart: entry.coverStart,
                coverEnd: entry.coverEnd
            )
        }
        if let index = entries.firstIndex(where: { $0.slug == entry.slug }) {
            added.isFavorite = entries[index].isFavorite
            entries[index] = added
        } else {
            entries.insert(added, at: 0)
        }
    }

    func isInLibrary(slug: String) async throws -> Bool {
        try await respond()
        return entries.contains { $0.slug == slug }
    }

    func entry(_ slug: String) -> LibraryEntry? {
        entries.first { $0.slug == slug }
    }

    func isFavorite(_ slug: String) -> Bool {
        entries.first { $0.slug == slug }?.isFavorite == true
    }

    func setFailure(_ error: Error?) {
        failure = error
    }

    private func respond() async throws {
        let error = failure
        try await Task.sleep(for: latency)
        if let error { throw error }
    }
}
