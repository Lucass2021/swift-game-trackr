import Foundation

actor FakeSetupRepository: SetupRepository {
    private static let fakeImageScheme = "fake://"

    private(set) var fetchCount = 0
    private var setups: [SetupItem]
    private var nextId: Int
    private var failure: Error?
    private let latency: Duration

    init(
        setups: [SetupItem] = ProfileMockData.setups,
        failure: Error? = nil,
        latency: Duration = FakeLatency.responseDelay
    ) {
        self.setups = setups
        self.failure = failure
        self.latency = latency
        let usedIds = setups.map(\.id) + setups.flatMap(\.images).map(\.id)
        nextId = (usedIds.max() ?? 0) + 1
    }

    func fetchSetups() async throws -> [SetupItem] {
        fetchCount += 1
        try await respond()
        return setups
    }

    func createSetup(title: String, description: String, images: [SetupImageUpload]) async throws -> SetupItem {
        try await respond()
        let setup = SetupItem(id: takeId(), title: title, description: description, images: images.map(fakeImage))
        setups.append(setup)
        return setup
    }

    func updateSetup(
        id: Int,
        title: String,
        description: String,
        newImages: [SetupImageUpload],
        removedImageIds: [Int]
    ) async throws -> SetupItem {
        try await respond()
        guard let index = setups.firstIndex(where: { $0.id == id }) else { throw APIError.notFound }
        var setup = setups[index]
        setup.title = title
        setup.description = description
        setup.images = setup.images.filter { !removedImageIds.contains($0.id) } + newImages.map(fakeImage)
        setups[index] = setup
        return setup
    }

    func deleteSetup(id: Int) async throws {
        try await respond()
        setups.removeAll { $0.id == id }
    }

    func setFailure(_ error: Error?) {
        failure = error
    }

    private func respond() async throws {
        let error = failure
        try await Task.sleep(for: latency)
        if let error { throw error }
    }

    private func takeId() -> Int {
        defer { nextId += 1 }
        return nextId
    }

    private func fakeImage(_ upload: SetupImageUpload) -> SetupImage {
        SetupImage(id: takeId(), url: Self.fakeImageScheme + upload.fileName)
    }
}
