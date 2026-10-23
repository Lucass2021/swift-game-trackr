import Foundation

@MainActor
@Observable
final class GameDetailViewModel {
    private(set) var game: GameDetail?
    private(set) var isLoading = false
    private(set) var hasError = false
    private(set) var isInLibrary = false
    var toastMessage: String?

    private let repository: GameRepository
    private let libraryRepository: LibraryRepository
    private let slug: String
    private var loadTask: Task<Void, Never>?
    private var libraryTask: Task<Void, Never>?

    init(
        slug: String,
        repository: GameRepository,
        libraryRepository: LibraryRepository,
        libraryUpdates: LibraryUpdates
    ) {
        self.slug = slug
        self.repository = repository
        self.libraryRepository = libraryRepository
        libraryUpdates.observe(self) { [weak self] addedSlug in
            guard let self, addedSlug == slug else { return }
            isInLibrary = true
        }
    }

    func loadIfNeeded() async {
        guard game == nil, !isLoading else { return }
        await load()
    }

    func load() async {
        loadTask?.cancel()
        isLoading = true
        hasError = false
        libraryTask?.cancel()
        let libraryTask = Task { await fetchLibraryStatus() }
        self.libraryTask = libraryTask
        let task = Task { await fetch() }
        loadTask = task
        await task.value
        await libraryTask.value
    }

    func onAddedToLibrary() {
        toastMessage = "Added to your library"
    }

    private func fetchLibraryStatus() async {
        guard let result = try? await libraryRepository.isInLibrary(slug: slug), !Task.isCancelled else { return }
        isInLibrary = result
    }

    private func fetch() async {
        do {
            let result = try await repository.fetchGame(slug: slug)
            guard !Task.isCancelled else { return }
            game = result
        } catch {
            guard !Task.isCancelled else { return }
            hasError = true
        }
        isLoading = false
    }
}
