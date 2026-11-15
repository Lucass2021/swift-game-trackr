import Testing
@testable import GameTrackr

struct IntPluralTests {
    @Test func oneUsesTheSingularWord() {
        #expect(1.plural(one: "second", other: "seconds") == "second")
    }

    @Test func zeroAndManyUseThePluralWord() {
        #expect(0.plural(one: "game", other: "games") == "games")
        #expect(2.plural(one: "game", other: "games") == "games")
    }
}
