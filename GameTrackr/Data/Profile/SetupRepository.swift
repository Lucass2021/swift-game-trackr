protocol SetupRepository: Sendable {
    func fetchSetups() async throws -> [SetupItem]
    func createSetup(title: String, description: String, images: [SetupImageUpload]) async throws -> SetupItem
    func updateSetup(
        id: Int,
        title: String,
        description: String,
        newImages: [SetupImageUpload],
        removedImageIds: [Int]
    ) async throws -> SetupItem
    func deleteSetup(id: Int) async throws
}
