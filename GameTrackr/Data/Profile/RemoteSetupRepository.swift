struct RemoteSetupRepository: SetupRepository {
    private enum Field {
        static let title = "title"
        static let description = "description"
        static let images = "images[]"
        static let removeImageIds = "remove_image_ids[]"
    }

    private let apiClient: APIClient

    nonisolated init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    func fetchSetups() async throws -> [SetupItem] {
        let response: SetupsResponse = try await apiClient.request(.setups)
        return response.data.map { SetupItem(dto: $0) }
    }

    func createSetup(title: String, description: String, images: [SetupImageUpload]) async throws -> SetupItem {
        let form = setupForm(title: title, description: description, images: images)
        let response: SetupResponse = try await apiClient.request(.createSetup, form: form)
        return SetupItem(dto: response.data)
    }

    func updateSetup(
        id: Int,
        title: String,
        description: String,
        newImages: [SetupImageUpload],
        removedImageIds: [Int]
    ) async throws -> SetupItem {
        var form = setupForm(title: title, description: description, images: newImages)
        for imageId in removedImageIds {
            form.addField(Field.removeImageIds, value: "\(imageId)")
        }
        let response: SetupResponse = try await apiClient.request(.updateSetup(id: id), form: form)
        return SetupItem(dto: response.data)
    }

    func deleteSetup(id: Int) async throws {
        let _: MessageResponse = try await apiClient.request(.deleteSetup(id: id))
    }

    private func setupForm(title: String, description: String, images: [SetupImageUpload]) -> MultipartForm {
        var form = MultipartForm()
        form.addField(Field.title, value: title)
        form.addField(Field.description, value: description)
        for image in images {
            form.addFile(Field.images, fileName: image.fileName, mimeType: image.mimeType, data: image.data)
        }
        return form
    }
}
