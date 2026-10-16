import Foundation

@MainActor
@Observable
final class MySetupViewModel {
    private(set) var setups: [SetupItem] = []
    private(set) var isLoading = false
    private(set) var hasError = false

    private let repository: SetupRepository
    private var loadTask: Task<Void, Never>?
    private var loadedUserId: Int?

    init(repository: SetupRepository = RemoteSetupRepository()) {
        self.repository = repository
    }

    func loadFor(_ userId: Int?) async {
        guard userId != loadedUserId else { return }
        loadedUserId = userId
        clear()
        guard userId != nil else { return }
        await load()
    }

    func load() async {
        loadTask?.cancel()
        isLoading = true
        hasError = false
        let task = Task { await fetch() }
        loadTask = task
        await task.value
    }

    private func clear() {
        loadTask?.cancel()
        loadTask = nil
        setups = []
        isLoading = false
        hasError = false
    }

    private func fetch() async {
        do {
            let result = try await repository.fetchSetups()
            guard !Task.isCancelled else { return }
            setups = result
        } catch {
            guard !Task.isCancelled else { return }
            hasError = true
        }
        isLoading = false
    }

    func onSetupSaved(_ setup: SetupItem) {
        if let index = setups.firstIndex(where: { $0.id == setup.id }) {
            setups[index] = setup
        } else {
            setups.append(setup)
        }
    }

    func onSetupDeleted(_ id: Int) {
        setups.removeAll { $0.id == id }
    }
}
