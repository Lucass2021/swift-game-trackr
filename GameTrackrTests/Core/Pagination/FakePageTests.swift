import Testing
@testable import GameTrackr

struct FakePageTests {
    private static let perPage = 3
    private static let items = ["a", "b", "c", "d", "e"]

    @Test func fakePageReturnsTheRequestedSliceWithPageMetadata() {
        let page = fakePage(items: Self.items, page: 2, perPage: Self.perPage)

        #expect(page.items == ["d", "e"])
        #expect(page.currentPage == 2)
        #expect(page.lastPage == 2)
        #expect(page.total == Self.items.count)
    }

    @Test func fakePageOfAnEmptyListIsASingleEmptyPage() {
        let page = fakePage(items: [String](), page: 1, perPage: Self.perPage)

        #expect(page.items.isEmpty)
        #expect(page.lastPage == 1)
        #expect(page.total == 0)
    }
}
