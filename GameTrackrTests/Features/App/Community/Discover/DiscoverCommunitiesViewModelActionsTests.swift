import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct DiscoverCommunitiesViewModelActionsTests {
    private static let overlapLatency: Duration = .milliseconds(50)

    private let remote = FakeCommunityRepository(latency: .zero)
    private let repository: FakeDiscoverCommunitiesRepository
    private let communityUpdates = CommunityUpdates()
    private let viewModel: DiscoverCommunitiesViewModel
    private let notJoinedId: Int

    init() throws {
        repository = FakeDiscoverCommunitiesRepository(remote: remote, latency: .zero)
        viewModel = DiscoverCommunitiesViewModel(repository: repository, communityUpdates: communityUpdates)
        notJoinedId = try #require(CommunityMockData.all.first { !$0.isJoined }).id
    }

    private func community(_ id: Int) throws -> Community {
        try #require(viewModel.communities.first { $0.id == id })
    }

    @Test func joiningSavesItInTheBackend() async throws {
        await viewModel.loadIfNeeded()

        try await viewModel.onJoinTap(community(notJoinedId))

        #expect(try community(notJoinedId).isJoined)
        #expect(await remote.isJoined(notJoinedId))
    }

    @Test func aJoinFailureRollsBackAndShowsAnError() async throws {
        await viewModel.loadIfNeeded()

        await repository.setFailure(APIError.networkFailure)
        try await viewModel.onJoinTap(community(notJoinedId))

        #expect(try !community(notJoinedId).isJoined)
        #expect(viewModel.toastMessage == "Couldn't join this community. Please try again.")
    }

    @Test func aDoubleTapOnJoinSendsOneRequest() async throws {
        let remote = FakeCommunityRepository(latency: Self.overlapLatency)
        let repository = FakeDiscoverCommunitiesRepository(remote: remote, latency: .zero)
        let viewModel = DiscoverCommunitiesViewModel(repository: repository, communityUpdates: CommunityUpdates())
        await viewModel.loadIfNeeded()
        let target = try #require(viewModel.communities.first { $0.id == notJoinedId })

        async let first: Void = viewModel.onJoinTap(target)
        async let second: Void = viewModel.onJoinTap(target)
        _ = await (first, second)

        #expect(await repository.setJoinedCount == 1)
    }

    @Test func leavingAsksForConfirmationAndSavesOnlyAfterConfirming() async throws {
        await viewModel.loadIfNeeded()
        try await viewModel.onJoinTap(community(notJoinedId))

        try await viewModel.onJoinTap(community(notJoinedId))

        #expect(viewModel.communityToLeave?.id == notJoinedId)
        #expect(try community(notJoinedId).isJoined)

        await viewModel.onLeaveConfirmed()

        #expect(viewModel.communityToLeave == nil)
        #expect(try !community(notJoinedId).isJoined)
        #expect(await !remote.isJoined(notJoinedId))
    }

    @Test func joiningACategoryCommunityDoesNotTouchTheBackend() async throws {
        await viewModel.loadIfNeeded()
        let target = try #require(DiscoverMockData.categoryCommunities.first { !$0.isJoined })
        await viewModel.onCategoryChange(target.category)

        try await viewModel.onJoinTap(community(target.id))

        #expect(try community(target.id).isJoined)
        #expect(await !remote.isJoined(target.id))
    }

    @Test func aJoinMadeInAnotherScreenUpdatesTheList() async throws {
        await viewModel.loadIfNeeded()

        communityUpdates.publish(communityId: notJoinedId, isJoined: true)

        #expect(try community(notJoinedId).isJoined)
    }

    @Test func createdAndRemovedCommunitiesUpdateTheList() async {
        await viewModel.loadIfNeeded()
        let created = Community(id: 9999, name: "Created")

        viewModel.onCommunityCreated(created)
        #expect(viewModel.communities.first?.id == created.id)

        viewModel.onCommunityRemoved(created.id)
        #expect(!viewModel.communities.contains { $0.id == created.id })
    }

    @Test func aLeaveFailureRollsBackAndShowsAnError() async throws {
        await viewModel.loadIfNeeded()
        try await viewModel.onJoinTap(community(notJoinedId))

        await repository.setFailure(APIError.networkFailure)
        try await viewModel.onJoinTap(community(notJoinedId))
        await viewModel.onLeaveConfirmed()

        #expect(try community(notJoinedId).isJoined)
        #expect(viewModel.toastMessage == "Couldn't leave this community. Please try again.")
    }

    @Test func dismissingTheLeaveConfirmationKeepsTheCommunityJoined() async throws {
        await viewModel.loadIfNeeded()
        try await viewModel.onJoinTap(community(notJoinedId))

        try await viewModel.onJoinTap(community(notJoinedId))
        viewModel.onLeaveDismissed()

        #expect(viewModel.communityToLeave == nil)
        #expect(try community(notJoinedId).isJoined)
        #expect(await repository.setJoinedCount == 1)
    }

    @Test func aCreatedCommunityIsNotAddedToAFilteredList() async {
        await viewModel.loadIfNeeded()
        await viewModel.onCategoryChange("RPG")

        viewModel.onCommunityCreated(Community(id: 9999, name: "Created"))

        #expect(!viewModel.communities.contains { $0.id == 9999 })
    }
}
