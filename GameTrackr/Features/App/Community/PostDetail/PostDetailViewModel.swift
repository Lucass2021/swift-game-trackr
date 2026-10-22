import Foundation

@MainActor
@Observable
final class PostDetailViewModel {
    private(set) var post: CommunityPost
    private(set) var comments: [PostComment] = []
    private(set) var hasLoadedComments = false
    private(set) var isLoadingComments = false
    private(set) var commentsFailed = false
    var showComments = false
    var draft = ""
    var replyingTo: PostComment?
    private(set) var isSubmitting = false
    var showDeleteConfirmation = false
    private(set) var isDeleted = false
    var toastMessage: String?

    var commentCount: Int {
        hasLoadedComments ? comments.totalCount : post.comments
    }

    private let repository: CommunityRepository
    private let feedRepository: CommunityFeedRepository
    private let postUpdates: PostUpdates
    private var commentsTask: Task<Void, Never>?
    private var isPostLikePending = false
    private var isBookmarkPending = false
    private var pendingCommentLikeIds: Set<Int> = []

    init(
        post: CommunityPost,
        repository: CommunityRepository,
        feedRepository: CommunityFeedRepository,
        postUpdates: PostUpdates
    ) {
        self.post = post
        self.repository = repository
        self.feedRepository = feedRepository
        self.postUpdates = postUpdates
    }

    func loadIfNeeded() async {
        guard !hasLoadedComments, !isLoadingComments else { return }
        await loadComments()
    }

    func loadComments() async {
        commentsTask?.cancel()
        isLoadingComments = true
        commentsFailed = false
        let task = Task { await fetchComments() }
        commentsTask = task
        await task.value
    }

    func onLike() async {
        guard !isPostLikePending else { return }
        isPostLikePending = true
        defer { isPostLikePending = false }
        let previous = post
        post.isLiked = !previous.isLiked
        post.likes = previous.likes + (post.isLiked ? 1 : -1)
        do {
            let status = try await repository.togglePostLike(id: previous.id)
            post.isLiked = status.isLiked
            post.likes = status.likes
            postUpdates.publish(post)
        } catch {
            post.isLiked = previous.isLiked
            post.likes = previous.likes
            toastMessage = "Couldn't update the like. Please try again."
        }
    }

    func onBookmark() async {
        guard !isBookmarkPending else { return }
        isBookmarkPending = true
        defer { isBookmarkPending = false }
        let previous = post.isBookmarked
        post.isBookmarked = !previous
        do {
            try await feedRepository.setBookmark(postId: post.id, isBookmarked: !previous)
            postUpdates.publish(post)
        } catch {
            post.isBookmarked = previous
            toastMessage = "Couldn't update the bookmark. Please try again."
        }
    }

    func onCommentsOpen() {
        showComments = true
    }

    func onReplyTap(_ comment: PostComment) {
        replyingTo = comment
    }

    func onReplyCancel() {
        replyingTo = nil
    }

    func onSend() async {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isSubmitting else { return }
        isSubmitting = true
        defer { isSubmitting = false }
        let target = replyingTo
        do {
            if let target {
                let created = try await repository.replyToComment(postId: post.id, commentId: target.id, comment: text)
                comments = comments.addingReply(to: target.id, created)
            } else {
                let created = try await repository.addComment(postId: post.id, comment: text)
                comments.append(created)
            }
            draft = ""
            replyingTo = nil
        } catch {
            toastMessage = "Couldn't send your comment. Please try again."
        }
    }

    func onCommentLike(_ commentId: Int) async {
        guard let previous = comments.findComment(id: commentId),
              !pendingCommentLikeIds.contains(commentId) else { return }
        pendingCommentLikeIds.insert(commentId)
        defer { pendingCommentLikeIds.remove(commentId) }
        let liked = !previous.isLiked
        updateCommentLike(commentId, isLiked: liked, likes: previous.likes + (liked ? 1 : -1))
        do {
            let status = try await repository.toggleCommentLike(postId: post.id, commentId: commentId)
            updateCommentLike(commentId, isLiked: status.isLiked, likes: status.likes)
        } catch {
            updateCommentLike(commentId, isLiked: previous.isLiked, likes: previous.likes)
            toastMessage = "Couldn't update the like. Please try again."
        }
    }

    func onDeleteRequest() {
        showDeleteConfirmation = true
    }

    func onDeleteConfirmed() async {
        showDeleteConfirmation = false
        do {
            try await repository.deletePost(id: post.id)
            isDeleted = true
        } catch APIError.notFound {
            isDeleted = true
        } catch {
            toastMessage = "Couldn't delete this post. Please try again."
        }
    }

    private func updateCommentLike(_ commentId: Int, isLiked: Bool, likes: Int) {
        comments = comments.replacingComment(id: commentId) { comment in
            comment.isLiked = isLiked
            comment.likes = likes
        }
    }

    private func fetchComments() async {
        do {
            let result = try await repository.fetchPostComments(postId: post.id)
            guard !Task.isCancelled else { return }
            comments = result
            hasLoadedComments = true
        } catch {
            guard !Task.isCancelled else { return }
            commentsFailed = true
        }
        isLoadingComments = false
    }
}
