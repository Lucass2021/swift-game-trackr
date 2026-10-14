struct FakeLibraryRepository: LibraryRepository {
    func fetchLibrary(page: Int, perPage: Int) async throws -> Page<LibraryEntry> {
        try await Task.sleep(for: FakeLatency.responseDelay)
        return fakePage(items: LibraryMockData.entries, page: page, perPage: perPage)
    }

    func fetchLibraryStats() async throws -> LibraryStats {
        try await Task.sleep(for: FakeLatency.responseDelay)
        return LibraryMockData.stats
    }
}
