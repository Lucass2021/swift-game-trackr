import Testing
import UIKit
@testable import GameTrackr

@MainActor
struct EditSetupViewModelTests {
    private static let title = "Main Battle Station"
    private static let setupId = 5
    private static let imageId = 9
    private static let imageURL = "http://localhost:8000/storage/9/desk.jpg"

    private static let sourceId = "library-photo"

    private static func photo(sourceId: String? = nil) -> SetupPhoto {
        let image = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { _ in }
        return SetupPhoto(image: image, sourceId: sourceId)
    }

    @Test func savingWithoutATitleShowsTheErrorAndDoesNotCreateTheSetup() async throws {
        let repository = FakeSetupRepository(setups: [], latency: .zero)
        let viewModel = EditSetupViewModel(setup: nil, repository: repository)

        let saved = await viewModel.save()

        #expect(viewModel.titleError == "Title is required")
        #expect(saved == nil)
        #expect(try await repository.fetchSetups().isEmpty)
    }

    @Test func aNewSetupIsCreatedWithItsPhotosAndTheAPIId() async {
        let repository = FakeSetupRepository(setups: [], latency: .zero)
        let viewModel = EditSetupViewModel(setup: nil, repository: repository)

        viewModel.title = "  \(Self.title)  "
        viewModel.onPhotosPicked([Self.photo()])
        let saved = await viewModel.save()

        let created = try? await repository.fetchSetups()
        #expect(created?.count == 1)
        #expect(saved?.id == created?.first?.id)
        #expect(saved?.title == Self.title)
        #expect(saved?.images.count == 1)
        #expect(viewModel.setupId == created?.first?.id)
        #expect(viewModel.isNew)
    }

    @Test func savingAgainAfterACreateDoesNotCreateAnotherSetup() async throws {
        let repository = FakeSetupRepository(setups: [], latency: .zero)
        let viewModel = EditSetupViewModel(setup: nil, repository: repository)

        viewModel.title = Self.title
        viewModel.onPhotosPicked([Self.photo()])
        _ = await viewModel.save()
        _ = await viewModel.save()

        let setups = try await repository.fetchSetups()
        #expect(setups.count == 1)
        #expect(setups.first?.images.count == 1)
    }

    @Test func removedPhotosAreSentAsRemovedImageIdsWhenUpdating() async {
        let setup = SetupItem(
            id: Self.setupId,
            title: Self.title,
            description: "",
            images: [SetupImage(id: Self.imageId, url: Self.imageURL)]
        )
        let viewModel = EditSetupViewModel(
            setup: setup,
            repository: FakeSetupRepository(setups: [setup], latency: .zero)
        )

        viewModel.onRemoveImage(Self.imageId)
        let saved = await viewModel.save()

        #expect(saved?.images.isEmpty == true)
        #expect(viewModel.removedImageIds.isEmpty)
    }

    @Test func pickedPhotosNeverGoPastThePhotoLimit() {
        let viewModel = EditSetupViewModel(setup: nil, repository: FakeSetupRepository(latency: .zero))

        viewModel.onPhotosPicked((0 ..< EditSetupViewModel.photoLimit + 2).map { _ in Self.photo() })

        #expect(viewModel.photoCount == EditSetupViewModel.photoLimit)
        #expect(viewModel.remainingPhotoSlots == 0)
    }

    @Test func aDescriptionOverTheLimitShowsTheError() async {
        let viewModel = EditSetupViewModel(setup: nil, repository: FakeSetupRepository(latency: .zero))

        viewModel.title = Self.title
        viewModel.description = String(repeating: "a", count: EditSetupViewModel.descriptionLimit + 1)
        _ = await viewModel.save()

        #expect(viewModel.descriptionError == "Description is too long")
    }

    @Test func theSamePhotoPickedTwiceIsAddedOnce() {
        let viewModel = EditSetupViewModel(setup: nil, repository: FakeSetupRepository(latency: .zero))

        viewModel.onPhotosPicked([Self.photo(sourceId: Self.sourceId), Self.photo(sourceId: Self.sourceId)])
        viewModel.onPhotosPicked([Self.photo(sourceId: Self.sourceId)])

        #expect(viewModel.newPhotos.count == 1)
    }

    @Test func aPhotoThatCannotBeReadShowsAnErrorInsteadOfSaving() async {
        let viewModel = EditSetupViewModel(
            setup: nil,
            repository: FakeSetupRepository(latency: .zero),
            encode: { _ in nil }
        )

        viewModel.title = Self.title
        viewModel.onPhotosPicked([Self.photo()])
        let saved = await viewModel.save()

        #expect(viewModel.errorMessage == "Couldn't read one of the photos. Please pick it again.")
        #expect(saved == nil)
    }

    @Test func deletingReturnsTheSetupId() async {
        let setup = SetupItem(id: Self.setupId, title: Self.title, description: "")
        let viewModel = EditSetupViewModel(
            setup: setup,
            repository: FakeSetupRepository(setups: [setup], latency: .zero)
        )

        let deletedId = await viewModel.delete()

        #expect(deletedId == Self.setupId)
    }
}
