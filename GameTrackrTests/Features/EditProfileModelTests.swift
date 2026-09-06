import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct EditProfileModelTests {
    private let profile = Profile(
        name: "Lucas Dias",
        username: "@lucasdias",
        bio: "Backlog enthusiast",
        joinedAt: "Jan 2026",
        avatarHex: "#7C5CFF",
        stats: ProfileStats(totalGames: 10, hours: 100, platinum: 2),
        visibility: .publicProfile
    )

    private func makeModel() -> EditProfileModel {
        EditProfileModel(profile: profile, service: FakeProfileService())
    }

    @Test func stripsTheAtSignWhenLoadingTheStoredUsername() {
        #expect(makeModel().username == "lucasdias")
    }

    @Test func rejectsANameThatIsEmptyTooShortOrOverTheLimit() {
        let model = makeModel()

        model.name = "   "
        #expect(model.nameError == "Name is required")

        model.name = "Lu"
        #expect(model.nameError == "At least 3 characters")

        model.name = String(repeating: "a", count: EditProfileModel.nameLimit + 1)
        #expect(model.nameError == "Name must be under 50 characters")

        model.name = String(repeating: "a", count: EditProfileModel.nameLimit)
        #expect(model.nameError == nil)
    }

    @Test func allowsOnlyLettersNumbersAndUnderscoreInTheUsername() {
        let model = makeModel()

        model.username = "lucas dias"
        #expect(model.usernameError == "Only letters, numbers and underscore")

        model.username = "lucas-dias"
        #expect(model.usernameError == "Only letters, numbers and underscore")

        model.username = "lucas.dias"
        #expect(model.usernameError == "Only letters, numbers and underscore")

        model.username = "lucas_dias_02"
        #expect(model.usernameError == nil)
    }

    @Test func lowercasesTheUsernameBeforeValidatingIt() {
        let model = makeModel()
        model.username = "LucasDias"

        #expect(model.usernameError == nil)
        #expect(model.previewUsername == "@lucasdias")
    }

    @Test func enforcesTheUsernameLengthBounds() {
        let model = makeModel()

        model.username = ""
        #expect(model.usernameError == "Username is required")

        model.username = "lu"
        #expect(model.usernameError == "At least 3 characters")

        model.username = String(repeating: "a", count: EditProfileModel.usernameLimit + 1)
        #expect(model.usernameError == "Username must be under 20 characters")
    }

    @Test func capsTheBioAndCountsDownTheRemainingCharacters() {
        let model = makeModel()

        model.bio = String(repeating: "a", count: EditProfileModel.bioLimit)
        #expect(model.bioError == nil)
        #expect(model.bioRemaining == 0)

        model.bio = String(repeating: "a", count: EditProfileModel.bioLimit + 1)
        #expect(model.bioError == "Bio must be under 160 characters")
        #expect(model.bioRemaining == -1)
    }

    @Test func startsWithNoPendingChanges() {
        #expect(!makeModel().hasChanges)
    }

    @Test func ignoresWhitespaceOnlyEditsWhenDecidingIfSomethingChanged() {
        let model = makeModel()

        model.name = "  Lucas Dias  "
        model.bio = " Backlog enthusiast "

        #expect(!model.hasChanges)
    }

    @Test func flagsAChangeOnEveryEditableField() {
        let colorChanged = makeModel()
        colorChanged.avatarHex = "#22C55E"
        #expect(colorChanged.hasChanges)

        let visibilityChanged = makeModel()
        visibilityChanged.visibility = .privateProfile
        #expect(visibilityChanged.hasChanges)

        let usernameChanged = makeModel()
        usernameChanged.username = "lucas"
        #expect(usernameChanged.hasChanges)
    }

    @Test func keepsErrorsHiddenUntilTheFirstSaveAttempt() async {
        let model = makeModel()
        model.username = "lu"

        #expect(model.visibleError(model.usernameError) == nil)

        _ = await model.save()

        #expect(model.visibleError(model.usernameError) == "At least 3 characters")
    }

    @Test func refusesToSaveAnInvalidForm() async {
        let model = makeModel()
        model.name = ""

        #expect(await model.save() == nil)
        #expect(!model.canSave)
    }

    @Test func fallsBackToTheOriginalValuesInThePreview() {
        let model = makeModel()
        model.name = ""
        model.username = ""

        #expect(model.previewName == "Lucas Dias")
        #expect(model.previewUsername == "@lucasdias")
    }
}
