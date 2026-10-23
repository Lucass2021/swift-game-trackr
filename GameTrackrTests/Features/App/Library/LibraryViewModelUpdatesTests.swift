import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct LibraryViewModelUpdatesTests {
    private static let userId = 7
    private static let entry = NewLibraryEntry(
        title: "Neon Ascent: Revival",
        slug: "neon-ascent-revival",
        status: .playing,
        rating: 0,
        hours: nil,
        platform: "PS5",
        startedAt: nil,
        finishedAt: nil,
        review: nil,
        coverStart: .coverVioletStart,
        coverEnd: .coverVioletEnd
    )

    @Test func aGameAddedFromItsDetailScreenShowsUpInTheLibrary() async throws {
        let repository = FakeLibraryRepository(latency: .zero)
        let libraryUpdates = LibraryUpdates()
        let viewModel = LibraryViewModel(repository: repository, libraryUpdates: libraryUpdates)
        await viewModel.loadFor(Self.userId)

        try await repository.addToLibrary(Self.entry)
        libraryUpdates.publish(Self.entry.slug)
        await viewModel.updateTask?.value

        #expect(viewModel.entries.contains { $0.slug == Self.entry.slug })
    }

    @Test func aSignedOutLibraryIgnoresAddedGames() async {
        let repository = FakeLibraryRepository(latency: .zero)
        let libraryUpdates = LibraryUpdates()
        let viewModel = LibraryViewModel(repository: repository, libraryUpdates: libraryUpdates)

        libraryUpdates.publish(Self.entry.slug)

        #expect(viewModel.updateTask == nil)
        #expect(await repository.fetchCount == 0)
    }
}
