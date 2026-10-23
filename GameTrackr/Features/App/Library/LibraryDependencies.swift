import Observation

@MainActor
@Observable
final class LibraryDependencies {
    let repository: LibraryRepository
    let libraryUpdates = LibraryUpdates()
    let viewModel: LibraryViewModel

    init(repository: LibraryRepository = FakeLibraryRepository()) {
        self.repository = repository
        viewModel = LibraryViewModel(repository: repository, libraryUpdates: libraryUpdates)
    }
}
