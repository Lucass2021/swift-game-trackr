import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct CreateCommunityModelTests {
    @Test func derivesTheHandleTheBackendWillActuallyStore() {
        let model = CreateCommunityModel()
        model.name = "Retro Shmup Club"

        #expect(model.handle == "RetroShmupClub")
        #expect(model.isRenamed)
    }

    @Test func doesNotFlagARenameWhenTheNameHasNoWhitespace() {
        let model = CreateCommunityModel()
        model.name = "RetroShmupClub"

        #expect(!model.isRenamed)
    }

    @Test func doesNotFlagARenameOnAnEmptyName() {
        let model = CreateCommunityModel()
        model.name = "   "

        #expect(model.handle.isEmpty)
        #expect(!model.isRenamed)
    }

    @Test func validatesTheHandleLengthNotTheTypedLength() {
        let model = CreateCommunityModel()
        model.name = "a b"

        #expect(model.name.count == 3)
        #expect(model.nameError == "Name must be at least 3 characters")

        model.name = "a b c"
        #expect(model.nameError == nil)
    }

    @Test func requiresAName() {
        let model = CreateCommunityModel()
        #expect(model.nameError == "Name is required")

        model.name = "   "
        #expect(model.nameError == "Name is required")
    }

    @Test func requiresADescriptionOfAtLeastTenCharacters() {
        let model = CreateCommunityModel()

        #expect(model.descriptionError == "Description is required")

        model.description = "  \n "
        #expect(model.descriptionError == "Description is required")

        model.description = "Too short"
        #expect(model.descriptionError == "Description must be at least 10 characters")

        model.description = "A club for retro shoot-em-ups."
        #expect(model.descriptionError == nil)
    }

    @Test func countsTheRemainingCharactersAgainstTheHandle() {
        let model = CreateCommunityModel()
        model.name = "Retro Shmup Club"

        #expect(model.nameRemaining == CreateCommunityModel.nameLimit - "RetroShmupClub".count)
    }

    @Test func onlyAllowsSubmitWhenBothFieldsAreValid() {
        let model = CreateCommunityModel()
        #expect(!model.canSubmit)

        model.name = "Retro Shmup Club"
        #expect(!model.canSubmit)

        model.description = "A club for retro shoot-em-ups."
        #expect(model.canSubmit)
    }

    @Test func considersTheFormDirtyAsSoonAsEitherFieldHasContent() {
        let model = CreateCommunityModel()
        #expect(!model.hasContent)

        model.name = "   "
        #expect(!model.hasContent)

        model.name = "A"
        #expect(model.hasContent)
    }

    @Test func keepsErrorsHiddenUntilTheFirstSubmitAttempt() {
        let model = CreateCommunityModel()

        #expect(model.visibleError(model.nameError) == nil)
        #expect(model.nameError != nil)
    }
}
