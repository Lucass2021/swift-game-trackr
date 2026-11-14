import Testing
@testable import GameTrackr

struct CoverPaletteTests {
    private static let gradientOrder: [CoverPalette] = [.emerald, .crimson, .indigo, .azure, .violet, .cyan, .pine]

    @Test func gradientIdsFollowTheGradientOrder() {
        #expect((0 ..< 7).map(CoverPalette.forGradientId) == Self.gradientOrder)
    }

    @Test func gradientIdsWrapAround() {
        #expect(CoverPalette.forGradientId(7) == .emerald)
    }

    @Test func aNegativeGradientIdUsesItsAbsoluteValue() {
        #expect(CoverPalette.forGradientId(-3) == CoverPalette.forGradientId(3))
    }

    @Test func setupIdsFollowTheCaseOrderAndWrapForNegativeIds() {
        #expect(CoverPalette.forId(0) == .violet)
        #expect(CoverPalette.forId(-1) == .pine)
    }
}
