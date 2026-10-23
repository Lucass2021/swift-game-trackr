protocol LibraryRepository: Sendable {
    func fetchLibrary(status: LibraryStatus?, page: Int, perPage: Int) async throws -> Page<LibraryEntry>
    func fetchLibraryStats() async throws -> LibraryStats
    func setFavorite(slug: String, isFavorite: Bool) async throws
    func addToLibrary(_ entry: NewLibraryEntry) async throws
    func isInLibrary(slug: String) async throws -> Bool
}
