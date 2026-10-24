import Testing
@testable import GameTrackr

@MainActor
struct ProfileMenuUiStateTests {
    private static let name = "Ada Lovelace"
    private static let email = "ada@example.com"

    @Test func aSignedInUserShowsTheirNameEmailAndEveryItem() {
        let state = ProfileMenuUiState(isGuest: false, userName: Self.name, email: Self.email)

        #expect(state.name == Self.name)
        #expect(state.subtitle == Self.email)
        #expect(state.accountItems == [.editProfile, .stats, .achievements])
        #expect(state.appItems == [.settings, .help, .about])
    }

    @Test func aGuestSeesTheGuestHeaderAndOnlyHelpAndAbout() {
        let state = ProfileMenuUiState(isGuest: true, userName: Self.name, email: Self.email)

        #expect(state.name == "Guest")
        #expect(state.subtitle == "Not signed in")
        #expect(state.accountItems.isEmpty)
        #expect(state.appItems == [.help, .about])
    }

    @Test func aSignedInUserNotLoadedYetShowsNoMockName() {
        let state = ProfileMenuUiState(isGuest: false, userName: nil, email: nil)

        #expect(state.name.isEmpty)
        #expect(state.subtitle.isEmpty)
    }

    @Test func aBlankNameOrEmailIsShownAsEmpty() {
        let state = ProfileMenuUiState(isGuest: false, userName: "  ", email: " ")

        #expect(state.name.isEmpty)
        #expect(state.subtitle.isEmpty)
    }
}
