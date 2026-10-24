import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct CommunityDetailViewModelActionsTests {
    private static let community = CommunityMockData.detailCommunity
    private static let post = CommunityMockData.communityPosts[0]
    private static let overlapLatency: Duration = .milliseconds(50)

    private let repository = FakeCommunityRepository(communities: [Self.community], latency: .zero)
    private let feedRepository: FakeCommunityFeedRepository
    private let postUpdates = PostUpdates()
    private let viewModel: CommunityDetailViewModel

    init() {
        feedRepository = FakeCommunityFeedRepository(remote: repository, latency: .zero)
        viewModel = CommunityDetailViewModel(
            community: Self.community,
            repository: repository,
            feedRepository: feedRepository,
            postUpdates: postUpdates,
            communityUpdates: CommunityUpdates()
        )
    }

    @Test func joiningSavesItInTheRepository() async {
        await viewModel.loadIfNeeded()

        await viewModel.onJoinTap()

        #expect(viewModel.isJoined)
        #expect(await repository.isJoined(Self.community.id))
    }

    @Test func aJoinFailureRollsBackAndShowsAnError() async {
        await viewModel.loadIfNeeded()

        await repository.setFailure(APIError.networkFailure)
        await viewModel.onJoinTap()

        #expect(!viewModel.isJoined)
        #expect(viewModel.toastMessage == "Couldn't join this community. Please try again.")
    }

    @Test func leavingAsksForConfirmationAndSavesOnlyAfterConfirming() async {
        await viewModel.loadIfNeeded()
        await viewModel.onJoinTap()

        await viewModel.onJoinTap()

        #expect(viewModel.showLeaveConfirmation)
        #expect(viewModel.isJoined)

        await viewModel.onLeaveConfirmed()

        #expect(!viewModel.showLeaveConfirmation)
        #expect(!viewModel.isJoined)
        #expect(await !repository.isJoined(Self.community.id))
    }

    @Test func aLikeIsShownRightAwayAndSyncedWithTheRepository() async {
        let repository = FakeCommunityRepository(latency: Self.overlapLatency)
        let viewModel = CommunityDetailViewModel(
            community: Self.community,
            repository: repository,
            feedRepository: FakeCommunityFeedRepository(
                remote: repository,
                latency: .zero
            ),
            postUpdates: PostUpdates(),
            communityUpdates: CommunityUpdates()
        )
        await viewModel.loadIfNeeded()

        let liking = Task { await viewModel.onLike(Self.post.id) }
        while await repository.likeCount == 0 {
            await Task.yield()
        }
        let optimistic = viewModel.posts.first { $0.id == Self.post.id }

        #expect(optimistic?.isLiked == true)
        #expect(optimistic?.likes == Self.post.likes + 1)

        await liking.value
        let stored = await repository.post(Self.post.id)

        #expect(viewModel.posts.first { $0.id == Self.post.id }?.likes == stored?.likes)
    }

    @Test func aLikeFailureRestoresThePreviousLikeAndShowsAnError() async {
        await viewModel.loadIfNeeded()

        await repository.setFailure(APIError.networkFailure)
        await viewModel.onLike(Self.post.id)

        #expect(!likedPost().isLiked)
        #expect(likedPost().likes == Self.post.likes)
        #expect(viewModel.toastMessage == "Couldn't update the like. Please try again.")
    }

    @Test func aSecondTapOnAPendingLikeIsIgnored() async {
        let repository = FakeCommunityRepository(latency: Self.overlapLatency)
        let viewModel = CommunityDetailViewModel(
            community: Self.community,
            repository: repository,
            feedRepository: FakeCommunityFeedRepository(
                remote: repository,
                latency: .zero
            ),
            postUpdates: PostUpdates(),
            communityUpdates: CommunityUpdates()
        )
        await viewModel.loadIfNeeded()

        async let first: Void = viewModel.onLike(Self.post.id)
        async let second: Void = viewModel.onLike(Self.post.id)
        _ = await (first, second)

        #expect(await repository.likeCount == 1)
        #expect(viewModel.posts.first { $0.id == Self.post.id }?.isLiked == true)
    }

    @Test func deletingReportsTheDeletedCommunity() async {
        await viewModel.loadIfNeeded()

        viewModel.onDeleteRequest()
        #expect(viewModel.showDeleteConfirmation)
        await viewModel.onDeleteConfirmed()

        #expect(viewModel.isDeleted)
        #expect(await repository.deleteCount == 1)
    }

    @Test func aForbiddenDeleteShowsTheOwnerMessage() async {
        await viewModel.loadIfNeeded()

        await repository.setFailure(APIError.forbidden("Forbidden"))
        await viewModel.onDeleteConfirmed()

        #expect(!viewModel.isDeleted)
        #expect(viewModel.toastMessage == "Only the community owner can delete it.")
    }

    @Test func aBookmarkIsSavedInTheRepositoryAndAFailureRollsBack() async {
        await viewModel.loadIfNeeded()

        await viewModel.onBookmark(Self.post.id)

        #expect(likedPost().isBookmarked)
        #expect(await feedRepository.isBookmarked(Self.post.id))

        await feedRepository.setFailure(APIError.networkFailure)
        await viewModel.onBookmark(Self.post.id)

        #expect(likedPost().isBookmarked)
        #expect(viewModel.toastMessage == "Couldn't update the bookmark. Please try again.")
    }

    private func likedPost() -> CommunityPost {
        viewModel.posts.first { $0.id == Self.post.id } ?? Self.post
    }
}
