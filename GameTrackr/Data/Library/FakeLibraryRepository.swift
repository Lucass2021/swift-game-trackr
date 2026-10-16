actor FakeLibraryRepository: LibraryRepository {
    private(set) var fetchCount = 0
    private(set) var setFavoriteCount = 0
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
