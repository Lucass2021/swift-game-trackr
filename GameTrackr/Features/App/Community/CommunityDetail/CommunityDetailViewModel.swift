import Foundation

@MainActor
@Observable
final class CommunityDetailViewModel {
    static let pageSize = 30

    private(set) var isJoined: Bool
    var tab: CommunityDetailTab = .posts
    private(set) var posts: [CommunityPost] = []
    private(set) var currentPage = 0
    private(set) var lastPage = 1
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var hasError = false
    private(set) var loadMoreFailed = false
    private(set) var members: [CommunityMember] = []
    private(set) var membersFailed = false
    var showLeaveConfirmation = false
    var showDeleteConfirmation = false
    private(set) var isDeleted = false
    var toastMessage: String?

    var isEmpty: Bool {
        currentPage > 0 && posts.isEmpty && !hasError
    }

    var canLoadMore: Bool {
        (1 ..< lastPage).contains(currentPage) && !isLoading && !isLoadingMore && !loadMoreFailed
    }

    private let repository: CommunityRepository
    private let community: Community
    private var postsTask: Task<Void, Never>?
    private var membersTask: Task<Void, Never>?
    private var isJoinPending = false
    private var pendingLikeIds: Set<Int> = []

    init(community: Community, repository: CommunityRepository) {
        self.community = community
        self.repository = repository
        isJoined = community.isJoined
    }

    func loadIfNeeded() async {
        guard currentPage == 0, !isLoading else { return }
        await load()
    }

    func load() async {
        await loadAll(isRefresh: false)
    }

    func refresh() async {
        await loadAll(isRefresh: true)
    }

    func loadMore() async {
        guard currentPage > 0, currentPage < lastPage, !isLoading, !isLoadingMore else { return }
        await loadPosts(page: currentPage + 1, isRefresh: false)
    }

    func retryMembers() async {
        await loadMembers()
    }

    func onJoinTap() async {
        guard !isJoinPending else { return }
        if isJoined {
            showLeaveConfirmation = true
        } else {
            await setJoined(true)
        }
    }

    func onLeaveConfirmed() async {
        showLeaveConfirmation = false
        await setJoined(false)
    }

    func onDeleteRequest() {
        showDeleteConfirmation = true
    }

    func onDeleteConfirmed() async {
        showDeleteConfirmation = false
        do {
            try await repository.deleteCommunity(id: community.id)
            isDeleted = true
        } catch APIError.forbidden {
            toastMessage = "Only the community owner can delete it."
        } catch {
            toastMessage = "Couldn't delete this community."
        }
    }

    func onLike(_ postId: Int) async {
        guard let previous = posts.first(where: { $0.id == postId }), !pendingLikeIds.contains(postId) else { return }
        pendingLikeIds.insert(postId)
        defer { pendingLikeIds.remove(postId) }
        let liked = !previous.isLiked
        updateLike(postId, isLiked: liked, likes: previous.likes + (liked ? 1 : -1))
        do {
            let status = try await repository.togglePostLike(id: postId)
            updateLike(postId, isLiked: status.isLiked, likes: status.likes)
        } catch {
            updateLike(postId, isLiked: previous.isLiked, likes: previous.likes)
            toastMessage = "Couldn't update the like. Please try again."
        }
    }

    func onBookmark(_ postId: Int) {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        posts[index].isBookmarked.toggle()
    }

    private func setJoined(_ joined: Bool) async {
        isJoinPending = true
        defer { isJoinPending = false }
        isJoined = joined
        do {
            if joined {
                try await repository.joinCommunity(id: community.id)
            } else {
                try await repository.leaveCommunity(id: community.id)
            }
        } catch {
            isJoined = !joined
            toastMessage = joined
                ? "Couldn't join this community. Please try again."
                : "Couldn't leave this community. Please try again."
        }
    }

    private func loadAll(isRefresh: Bool) async {
        async let postsLoad: Void = loadPosts(page: 1, isRefresh: isRefresh)
        async let membersLoad: Void = loadMembers()
        _ = await (postsLoad, membersLoad)
    }

    private func updateLike(_ postId: Int, isLiked: Bool, likes: Int) {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        posts[index].isLiked = isLiked
        posts[index].likes = likes
    }

    private func loadPosts(page: Int, isRefresh: Bool) async {
        postsTask?.cancel()
        if page == 1, !isRefresh {
            posts = []
            currentPage = 0
            lastPage = 1
            isLoading = true
            isLoadingMore = false
        } else if page > 1 {
            isLoadingMore = true
        }
        hasError = false
        loadMoreFailed = false
        let task = Task { await fetchPosts(page: page, isRefresh: isRefresh) }
        postsTask = task
        await task.value
    }

    private func fetchPosts(page: Int, isRefresh: Bool) async {
        do {
            let result = try await repository.fetchPosts(page: page, perPage: Self.pageSize, communityId: community.id)
            guard !Task.isCancelled else { return }
            posts = page == 1 ? result.items : posts + result.items
            currentPage = result.currentPage
            lastPage = result.lastPage
        } catch {
            guard !Task.isCancelled else { return }
            hasError = page == 1 && posts.isEmpty
            loadMoreFailed = page > 1
            if isRefresh, !posts.isEmpty { toastMessage = "Couldn't refresh. Please try again." }
        }
        isLoading = false
        isLoadingMore = false
    }

    private func loadMembers() async {
        membersTask?.cancel()
        membersFailed = false
        let task = Task { await fetchMembers() }
        membersTask = task
        await task.value
    }

    private func fetchMembers() async {
        do {
            let result = try await repository.fetchCommunityMembers(id: community.id)
            guard !Task.isCancelled else { return }
            members = result
        } catch {
            guard !Task.isCancelled else { return }
            membersFailed = true
        }
    }
}
