import Testing
@testable import GameTrackr

@MainActor
struct AboutUiStateTests {
    @Test func theVersionTextShowsTheBuildVersion() {
        let state = AboutUiState(versionName: "2.4")

        #expect(state.versionText == "Version 2.4")
    }
}
