import Foundation

@MainActor
@Observable
final class EditSetupViewModel {
    static let photoLimit = 10
    static let titleLimit = 255
    static let descriptionLimit = 5000

    let isNew: Bool
    private(set) var setupId: Int?
    var title: String
    var description: String
    private(set) var images: [SetupImage]
    private(set) var newPhotos: [SetupPhoto] = []
    private(set) var removedImageIds: [Int] = []
    private(set) var isSaving = false
    private(set) var isDeleting = false
    private(set) var hasAttemptedSave = false
    var errorMessage: String?

    private let repository: SetupRepository
    private let encode: @Sendable (SetupPhoto) -> SetupImageUpload?

    init(
        setup: SetupItem?,
        repository: SetupRepository = RemoteSetupRepository(),
        encode: @escaping @Sendable (SetupPhoto) -> SetupImageUpload? = SetupPhotoEncoder.encode
    ) {
        isNew = setup == nil
        setupId = setup?.id
        title = setup?.title ?? ""
        description = setup?.description ?? ""
        images = setup?.images ?? []
        self.repository = repository
        self.encode = encode
    }

    var photoCount: Int {
        images.count + newPhotos.count
    }

    var remainingPhotoSlots: Int {
        max(Self.photoLimit - photoCount, 0)
    }

    var isBusy: Bool {
        isSaving || isDeleting
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedDescription: String {
        description.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var titleError: String? {
        guard hasAttemptedSave else { return nil }
        if trimmedTitle.isEmpty { return "Title is required" }
        if trimmedTitle.count > Self.titleLimit { return "Title is too long" }
        return nil
    }

    var descriptionError: String? {
        guard hasAttemptedSave else { return nil }
        return trimmedDescription.count > Self.descriptionLimit ? "Description is too long" : nil
    }

    func onPhotosPicked(_ photos: [SetupPhoto]) {
        var knownSources = Set(newPhotos.compactMap(\.sourceId))
        let picked = photos.filter { photo in
            guard let sourceId = photo.sourceId else { return true }
            return knownSources.insert(sourceId).inserted
        }
        newPhotos += picked.prefix(remainingPhotoSlots)
    }

    func onRemoveImage(_ id: Int) {
        images.removeAll { $0.id == id }
        removedImageIds.append(id)
    }

    func onRemoveNewPhoto(_ photo: SetupPhoto) {
        newPhotos.removeAll { $0.id == photo.id }
    }

    func save() async -> SetupItem? {
        hasAttemptedSave = true
        guard titleError == nil, descriptionError == nil, !isBusy else { return nil }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        let photos = newPhotos
        let encode = encode
        let uploads = await Task.detached { photos.compactMap(encode) }.value
        guard uploads.count == photos.count else {
            errorMessage = "Couldn't read one of the photos. Please pick it again."
            return nil
        }

        do {
            let saved = try await persist(uploads)
            setupId = saved.id
            images = saved.images
            newPhotos = []
            removedImageIds = []
            return saved
        } catch {
            errorMessage = "Couldn't save your setup. Please try again."
            return nil
        }
    }

    private func persist(_ uploads: [SetupImageUpload]) async throws -> SetupItem {
        guard let setupId else {
            return try await repository.createSetup(
                title: trimmedTitle,
                description: trimmedDescription,
                images: uploads
            )
        }
        return try await repository.updateSetup(
            id: setupId,
            title: trimmedTitle,
            description: trimmedDescription,
            newImages: uploads,
            removedImageIds: removedImageIds
        )
    }

    func delete() async -> Int? {
        guard let setupId, !isBusy else { return nil }
        isDeleting = true
        errorMessage = nil
        defer { isDeleting = false }

        do {
            try await repository.deleteSetup(id: setupId)
            return setupId
        } catch {
            errorMessage = "Couldn't delete your setup. Please try again."
            return nil
        }
    }
}
