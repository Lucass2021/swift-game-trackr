import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct PostDetailViewModelTests {
    private static let post = CommunityMockData.communityPosts[0]
    private static let overlapLatency: Duration = .milliseconds(50)

    private let repository = FakeCommunityRepository(latency: .zero)
    private let viewModel: PostDetailViewModel

    init() {
        viewModel = PostDetailViewModel(
            post: Self.post,
            repository: repository,
            feedRepository: FakeCommunityFeedRepository(
                remote: repository,
                latency: .zero
            ),
            postUpdates: PostUpdates()
        )
    }

    @Test func loadingShowsTheCommentsAndTheirRealCount() async {
        await viewModel.loadIfNeeded()

        #expect(viewModel.comments.map(\.id) == CommunityMockData.comments.map(\.id))
        #expect(viewModel.hasLoadedComments)
        #expect(viewModel.commentCount == CommunityMockData.comments.totalCount)
    }

    @Test func theCommentCountUsesThePostUntilTheCommentsLoad() async {
        #expect(viewModel.commentCount == Self.post.comments)

        await viewModel.loadIfNeeded()

        #expect(viewModel.commentCount == CommunityMockData.comments.totalCount)
    }

    @Test func aCommentsFailureShowsTheErrorInsteadOfAnEmptyList() async {
        await repository.setFailure(APIError.networkFailure)

        await viewModel.loadIfNeeded()

        #expect(viewModel.commentsFailed)
        #expect(!viewModel.hasLoadedComments)
        #expect(!viewModel.isLoadingComments)
    }

    @Test func retryingAfterAFailureLoadsTheComments() async {
        await repository.setFailure(APIError.networkFailure)
        await viewModel.loadIfNeeded()

        await repository.setFailure(nil)
        await viewModel.loadComments()

        #expect(!viewModel.commentsFailed)
        #expect(viewModel.comments.map(\.id) == CommunityMockData.comments.map(\.id))
    }

    @Test func returningToTheScreenDoesNotReloadTheComments() async {
        await viewModel.loadIfNeeded()

        await viewModel.loadIfNeeded()

        #expect(await repository.fetchCommentsCount == 1)
    }

    @Test func theSheetOpensWhileTheCommentsAreStillLoading() async {
        let repository = FakeCommunityRepository(latency: Self.overlapLatency)
        let viewModel = PostDetailViewModel(
            post: Self.post,
            repository: repository,
            feedRepository: FakeCommunityFeedRepository(
                remote: repository,
                latency: .zero
            ),
            postUpdates: PostUpdates()
        )

        let loading = Task { await viewModel.loadIfNeeded() }
        while await repository.fetchCommentsCount == 0 {
            await Task.yield()
        }
        viewModel.onCommentsOpen()

        #expect(viewModel.showComments)
        #expect(viewModel.isLoadingComments)

        await loading.value
    }

    @Test func aCommentSentSurvivesClosingAndReopeningTheSheet() async {
        await viewModel.loadIfNeeded()
        viewModel.onCommentsOpen()

        viewModel.draft = "Great post"
        await viewModel.onSend()
        viewModel.showComments = false
        viewModel.onCommentsOpen()

        #expect(viewModel.comments.last?.content == "Great post")
        #expect(viewModel.comments.count == CommunityMockData.comments.count + 1)
    }

    @Test func deletingAsksForConfirmationAndClosesAfterItIsDeleted() async {
        viewModel.onDeleteRequest()

        #expect(viewModel.showDeleteConfirmation)

        await viewModel.onDeleteConfirmed()

        #expect(!viewModel.showDeleteConfirmation)
        #expect(viewModel.isDeleted)
        #expect(await repository.post(Self.post.id) == nil)
    }

    @Test func deletingAPostThatIsAlreadyGoneStillCloses() async {
        let viewModel = PostDetailViewModel(
            post: Self.post,
            repository: FakeCommunityRepository(posts: [], latency: .zero),
            feedRepository: FakeCommunityFeedRepository(remote: FakeCommunityRepository()),
            postUpdates: PostUpdates()
        )

        await viewModel.onDeleteConfirmed()

        #expect(viewModel.isDeleted)
    }

    @Test func aDeleteFailureShowsAnErrorAndStaysOnThePost() async {
        await repository.setFailure(APIError.networkFailure)

        await viewModel.onDeleteConfirmed()

        #expect(!viewModel.isDeleted)
        #expect(viewModel.toastMessage == "Couldn't delete this post. Please try again.")
    }
}
