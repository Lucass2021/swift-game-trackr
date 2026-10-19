import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct PostDetailViewModelActionsTests {
    private static let post = CommunityMockData.communityPosts[0]
    private static let thread = CommunityMockData.comments[0]
    private static let reply = CommunityMockData.comments[0].replies[0]
    private static let overlapLatency: Duration = .milliseconds(50)
    private static let likeError = "Couldn't update the like. Please try again."

    private let repository = FakeCommunityRepository(latency: .zero)
    private let viewModel: PostDetailViewModel

    init() {
        viewModel = PostDetailViewModel(post: Self.post, repository: repository)
    }

    @Test func aPostLikeIsShownRightAwayAndSyncedWithTheRepository() async {
        let repository = FakeCommunityRepository(latency: Self.overlapLatency)
        let viewModel = PostDetailViewModel(post: Self.post, repository: repository)

        let liking = Task { await viewModel.onLike() }
        while await repository.likeCount == 0 {
            await Task.yield()
        }

        #expect(viewModel.post.isLiked == !Self.post.isLiked)

        await liking.value
        let stored = await repository.post(Self.post.id)

        #expect(stored?.isLiked == !Self.post.isLiked)
        #expect(viewModel.post.likes == stored?.likes)
    }

    @Test func aPostLikeFailureRestoresThePostAndShowsAnError() async {
        await repository.setFailure(APIError.networkFailure)

        await viewModel.onLike()

        #expect(viewModel.post.isLiked == Self.post.isLiked)
        #expect(viewModel.post.likes == Self.post.likes)
        #expect(viewModel.toastMessage == Self.likeError)
    }

    @Test func aSecondLikeTapWhileOneIsPendingIsIgnored() async {
        let repository = FakeCommunityRepository(latency: Self.overlapLatency)
        let viewModel = PostDetailViewModel(post: Self.post, repository: repository)

        async let first: Void = viewModel.onLike()
        async let second: Void = viewModel.onLike()
        _ = await (first, second)

        #expect(await repository.likeCount == 1)
    }

    @Test func aReplyLikeIsSavedInTheRepository() async {
        await viewModel.loadIfNeeded()

        await viewModel.onCommentLike(Self.reply.id)

        #expect(await repository.commentLikeCount == 1)
        #expect(await repository.comment(Self.reply.id)?.isLiked == !Self.reply.isLiked)
        #expect(viewModel.comments.findComment(id: Self.reply.id)?.isLiked == !Self.reply.isLiked)
    }

    @Test func aCommentLikeFailureRestoresTheCommentAndShowsAnError() async {
        await viewModel.loadIfNeeded()
        await repository.setFailure(APIError.networkFailure)

        await viewModel.onCommentLike(Self.thread.id)

        let restored = viewModel.comments.findComment(id: Self.thread.id)
        #expect(restored?.isLiked == Self.thread.isLiked)
        #expect(restored?.likes == Self.thread.likes)
        #expect(viewModel.toastMessage == Self.likeError)
    }

    @Test func sendingACommentAppendsItAndClearsTheDraft() async {
        await viewModel.loadIfNeeded()

        viewModel.draft = "  Nice  "
        await viewModel.onSend()

        #expect(viewModel.comments.last?.content == "Nice")
        #expect(viewModel.draft.isEmpty)
    }

    @Test func aReplyToAReplyGoesToTheRootThread() async {
        await viewModel.loadIfNeeded()

        viewModel.onReplyTap(Self.reply)
        viewModel.draft = "Agreed"
        await viewModel.onSend()

        #expect(viewModel.comments.first?.replies.last?.content == "Agreed")
        #expect(viewModel.replyingTo == nil)
    }

    @Test func aSendFailureKeepsTheDraftAndShowsAnError() async {
        await viewModel.loadIfNeeded()
        await repository.setFailure(APIError.networkFailure)

        viewModel.onReplyTap(Self.thread)
        viewModel.draft = "Keep me"
        await viewModel.onSend()

        #expect(viewModel.draft == "Keep me")
        #expect(viewModel.replyingTo?.id == Self.thread.id)
        #expect(viewModel.comments.count == CommunityMockData.comments.count)
        #expect(viewModel.toastMessage == "Couldn't send your comment. Please try again.")
    }

    @Test func aDoubleTapOnSendSendsOnce() async {
        let repository = FakeCommunityRepository(latency: Self.overlapLatency)
        let viewModel = PostDetailViewModel(post: Self.post, repository: repository)
        await viewModel.loadIfNeeded()

        viewModel.draft = "Once"
        async let first: Void = viewModel.onSend()
        async let second: Void = viewModel.onSend()
        _ = await (first, second)

        #expect(await repository.sendCommentCount == 1)
    }
}
