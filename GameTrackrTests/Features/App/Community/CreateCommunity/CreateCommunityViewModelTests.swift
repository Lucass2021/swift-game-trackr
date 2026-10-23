import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct CreateCommunityViewModelTests {
    private static let name = "RetroClub"
    private static let description = "A club for retro games."

    private let repository = FakeCommunityRepository(latency: .zero)

    private func viewModel(name: String? = nil, description: String? = nil) -> CreateCommunityViewModel {
        let viewModel = CreateCommunityViewModel(repository: repository)
        viewModel.onNameChange(name ?? Self.name)
        viewModel.onDescriptionChange(description ?? Self.description)
        return viewModel
    }

    @Test func nameSpacesAreRemovedFromTheHandle() {
        let viewModel = viewModel(name: "Retro Collectors")

        #expect(viewModel.handle == "RetroCollectors")
        #expect(viewModel.isRenamed)
    }

    @Test func errorsShowOnlyAfterTheFirstSubmit() async {
        let viewModel = viewModel(name: "", description: "")
        #expect(viewModel.nameError == nil)

        let created = await viewModel.submit()

        #expect(created == nil)
        #expect(viewModel.nameError == "Name is required")
        #expect(await repository.createCommunityCount == 0)
    }

    @Test func submitCreatesTheCommunityWithTheHandleAndTheTrimmedDescription() async {
        let viewModel = viewModel(name: "Retro Collectors", description: "  \(Self.description)  ")

        let created = await viewModel.submit()

        #expect(created?.name == "RetroCollectors")
        #expect(created?.description == Self.description)
        #expect(created?.isJoined == true)
        #expect(!viewModel.isSubmitting)
    }

    @Test func serverErrorSaysTheNameMayBeTakenAndKeepsTheForm() async {
        await repository.setFailure(APIError.serverError)
        let viewModel = viewModel()

        let created = await viewModel.submit()

        #expect(created == nil)
        #expect(viewModel.toastMessage == "Couldn't create the community. That name may already be taken.")
        #expect(viewModel.name == Self.name)
    }

    @Test func otherErrorsShowTheAPIMessage() async {
        await repository.setFailure(APIError.networkFailure)
        let viewModel = viewModel()

        _ = await viewModel.submit()

        #expect(viewModel.toastMessage == APIError.networkFailure.userMessage())
    }

    @Test func submitAfterASuccessfulCreateSendsNoRequest() async {
        let viewModel = viewModel()
        _ = await viewModel.submit()

        let second = await viewModel.submit()

        #expect(second == nil)
        #expect(await repository.createCommunityCount == 1)
    }

    @Test func descriptionLimitIgnoresSurroundingWhitespace() {
        let body = String(repeating: "a", count: CreateCommunityViewModel.descriptionLimit)
        let viewModel = viewModel(description: "  \(body)  ")

        #expect(viewModel.canSubmit)
    }
}
