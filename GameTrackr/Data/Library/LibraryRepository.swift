protocol LibraryRepository: Sendable {
    func fetchLibrary(page: Int, perPage: Int) async throws -> Page<LibraryEntry>
    func fetchLibraryStats() async throws -> LibraryStats
}
