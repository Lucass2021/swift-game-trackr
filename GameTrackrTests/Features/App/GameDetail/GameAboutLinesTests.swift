import Testing
@testable import GameTrackr

@MainActor
struct GameAboutLinesTests {
    @Test func shortSummaryIsFullyShownWithoutReadMore() {
        #expect(GameAboutLines.maxLines(expanded: false, collapsible: false) == nil)
        #expect(!GameAboutLines.showsToggle(collapsible: false))
    }

    @Test func longSummaryCollapsesWithReadMoreAndExpandsFully() {
        #expect(GameAboutLines.maxLines(expanded: false, collapsible: true) == GameAboutLines.collapsed)
        #expect(GameAboutLines.maxLines(expanded: true, collapsible: true) == nil)
        #expect(GameAboutLines.showsToggle(collapsible: true))
    }

    @Test func unmeasuredSummaryIsLimitedToTheFullyShownLinesWithoutReadMore() {
        #expect(GameAboutLines.maxLines(expanded: false, collapsible: nil) == GameAboutLines.fullyShownMax)
        #expect(!GameAboutLines.showsToggle(collapsible: nil))
    }

    @Test func expandedButUnmeasuredSummaryIsLimitedToTheFullyShownLines() {
        #expect(GameAboutLines.maxLines(expanded: true, collapsible: nil) == GameAboutLines.fullyShownMax)
    }
}
