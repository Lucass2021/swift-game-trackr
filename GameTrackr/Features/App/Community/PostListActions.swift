import Foundation

@MainActor
final class PostListActions {
    private let repository: CommunityRepository
    private let feedRepository: CommunityFeedRepository
    private let postUpdates: PostUpdates
    private let posts: () -> [CommunityPost]
    private let replacePost: (CommunityPost) -> Void
    private let showToast: (String) -> Void
    private var pendingLikeIds: Set<Int> = []
    private var pendingBookmarkIds: Set<Int> = []

    init(
        repository: CommunityRepository,
        feedRepository: CommunityFeedRepository,
        postUpdates: PostUpdates,
        posts: @escaping () -> [CommunityPost],
        replacePost: @escaping (CommunityPost) -> Void,
        showToast: @escaping (String) -> Void
    ) {
        self.repository = repository
        self.feedRepository = feedRepository
        self.postUpdates = postUpdates
        self.posts = posts
        self.replacePost = replacePost
        self.showToast = showToast
        postUpdates.observe(self) { [weak self] post in self?.replacePost(post) }
    }

    func onLike(_ postId: Int) async {
        guard var optimistic = post(postId), !pendingLikeIds.contains(postId) else { return }
        pendingLikeIds.insert(postId)
        defer { pendingLikeIds.remove(postId) }
        let previous = optimistic
        optimistic.isLiked = !previous.isLiked
        optimistic.likes = previous.likes + (optimistic.isLiked ? 1 : -1)
        replacePost(optimistic)
        do {
            let status = try await repository.togglePostLike(id: postId)
            update(postId) {
                $0.isLiked = status.isLiked
                $0.likes = status.likes
            }
            publish(postId)
        } catch {
            update(postId) {
                $0.isLiked = previous.isLiked
                $0.likes = previous.likes
            }
            showToast("Couldn't update the like. Please try again.")
        }
    }

    func onBookmark(_ postId: Int) async {
        guard let previous = post(postId), !pendingBookmarkIds.contains(postId) else { return }
        pendingBookmarkIds.insert(postId)
        defer { pendingBookmarkIds.remove(postId) }
        update(postId) { $0.isBookmarked = !previous.isBookmarked }
        do {
            try await feedRepository.setBookmark(postId: postId, isBookmarked: !previous.isBookmarked)
            publish(postId)
        } catch {
            update(postId) { $0.isBookmarked = previous.isBookmarked }
            showToast("Couldn't update the bookmark. Please try again.")
        }
    }

    private func post(_ postId: Int) -> CommunityPost? {
        posts().first { $0.id == postId }
    }

    private func update(_ postId: Int, _ change: (inout CommunityPost) -> Void) {
        guard var post = post(postId) else { return }
        change(&post)
        replacePost(post)
    }

    private func publish(_ postId: Int) {
        if let post = post(postId) {
            postUpdates.publish(post)
        }
    }
}
