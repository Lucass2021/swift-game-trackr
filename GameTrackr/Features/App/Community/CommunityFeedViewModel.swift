import Foundation

@MainActor
@Observable
final class CommunityFeedViewModel {
    static let pageSize = 20

    private(set) var filter: CommunityFeedFilter = .latest
    private(set) var posts: [CommunityPost] = []
    private(set) var currentPage = 0
    private(set) var lastPage = 1
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var isRefreshing = false
    private(set) var hasError = false
    private(set) var loadMoreFailed = false
    private(set) var suggestedCommunity: Community?
    var toastMessage: String?

    var isEmpty: Bool {
        currentPage > 0 && posts.isEmpty && !hasError
    }

    var canLoadMore: Bool {
        (1 ..< lastPage).contains(currentPage) && !isLoading && !isLoadingMore && !isRefreshing && !loadMoreFailed
    }

    private let feedRepository: CommunityFeedRepository
    private let repository: CommunityRepository
    private let communityUpdates: CommunityUpdates
    @ObservationIgnored private var postActions: PostListActions?
    private var postsTask: Task<Void, Never>?
    private var isJoinPending = false

    init(
        feedRepository: CommunityFeedRepository,
        repository: CommunityRepository,
        postUpdates: PostUpdates,
        communityUpdates: CommunityUpdates
    ) {
        self.feedRepository = feedRepository
        self.repository = repository
        self.communityUpdates = communityUpdates
        postActions = PostListActions(
            repository: repository,
            feedRepository: feedRepository,
            postUpdates: postUpdates,
            posts: { [weak self] in self?.posts ?? [] },
            replacePost: { [weak self] in self?.replacePost($0) },
            addPost: { [weak self] in self?.onPostCreated($0) },
            showToast: { [weak self] in self?.toastMessage = $0 }
        )
        communityUpdates.observe(self) { [weak self] join in
            guard self?.suggestedCommunity?.id == join.communityId else { return }
            self?.suggestedCommunity?.isJoined = join.isJoined
        }
    }

    func loadIfNeeded() async {
        guard currentPage == 0, !isLoading else { return }
        await load()
    }

    func load() async {
        await loadAll(isRefresh: false)
    }

    func refresh() async {
        isRefreshing = true
        defer { isRefreshing = false }
        await loadAll(isRefresh: true)
    }

    func loadMore() async {
        guard currentPage > 0, currentPage < lastPage, !isLoading, !isLoadingMore, !isRefreshing else { return }
        await loadPosts(page: currentPage + 1, isRefresh: false)
    }

    func onFilterChange(_ filter: CommunityFeedFilter) async {
        guard filter != self.filter else { return }
        self.filter = filter
        await loadPosts(page: 1, isRefresh: false)
    }

    func onLike(_ postId: Int) async {
        await postActions?.onLike(postId)
    }

    func onBookmark(_ postId: Int) async {
        await postActions?.onBookmark(postId)
    }

    func onJoinSuggested() async {
        guard let community = suggestedCommunity, !community.isJoined, !isJoinPending else { return }
        isJoinPending = true
        defer { isJoinPending = false }
        suggestedCommunity?.isJoined = true
        do {
            try await repository.joinCommunity(id: community.id)
            communityUpdates.publish(communityId: community.id, isJoined: true)
        } catch {
            suggestedCommunity = community
            toastMessage = "Couldn't join this community. Please try again."
        }
    }

    func onPostCreated(_ post: CommunityPost) {
        posts = posts.prependingPost(post)
    }

    func onPostDeleted(_ postId: Int) {
        posts.removeAll { $0.id == postId }
    }

    func onCommunityRemoved(_ communityId: Int) {
        posts.removeAll { $0.communityId == communityId }
        if suggestedCommunity?.id == communityId { suggestedCommunity = nil }
    }

    private func replacePost(_ post: CommunityPost) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[index] = post
    }

    private func loadAll(isRefresh: Bool) async {
        async let postsLoad: Void = loadPosts(page: 1, isRefresh: isRefresh)
        async let suggestionLoad: Void = loadSuggestion()
        _ = await (postsLoad, suggestionLoad)
    }

    private func loadSuggestion() async {
        if let community = try? await feedRepository.fetchSuggestedCommunity() {
            suggestedCommunity = community
        }
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
            let result = try await feedRepository.fetchFeed(filter: filter, page: page, perPage: Self.pageSize)
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
}
