import Foundation

@MainActor
@Observable
final class DiscoverCommunitiesViewModel {
    static let allCategory = "All"
    static let pageSize = 30
    static let searchDebounce: Duration = .milliseconds(300)

    private(set) var query = ""
    private(set) var category = DiscoverCommunitiesViewModel.allCategory
    private(set) var communities: [Community] = []
    private(set) var currentPage = 0
    private(set) var lastPage = 1
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var hasError = false
    private(set) var loadMoreFailed = false
    private(set) var communityToLeave: Community?
    var toastMessage: String?

    var isEmpty: Bool {
        currentPage > 0 && communities.isEmpty && !hasError
    }

    var canLoadMore: Bool {
        (1 ..< lastPage).contains(currentPage) && !isLoading && !isLoadingMore && !loadMoreFailed
    }

    private let repository: DiscoverCommunitiesRepository
    private let communityUpdates: CommunityUpdates
    private let searchDebounce: Duration
    private var pageTask: Task<Void, Never>?
    private var searchTask: Task<Void, Never>?
    private var pendingJoinIds: Set<Int> = []
    private var appliedCategory: String?
    private var appliedSearch: String?

    init(
        repository: DiscoverCommunitiesRepository,
        communityUpdates: CommunityUpdates,
        searchDebounce: Duration = DiscoverCommunitiesViewModel.searchDebounce
    ) {
        self.repository = repository
        self.communityUpdates = communityUpdates
        self.searchDebounce = searchDebounce
        communityUpdates.observe(self) { [weak self] join in
            self?.replaceJoined(join.communityId, isJoined: join.isJoined)
        }
    }

    func loadIfNeeded() async {
        guard currentPage == 0, !isLoading else { return }
        await load()
    }

    func load() async {
        searchTask?.cancel()
        await loadPage(1)
    }

    func loadMore() async {
        guard currentPage > 0, currentPage < lastPage, !isLoading, !isLoadingMore else { return }
        await loadPage(currentPage + 1)
    }

    @discardableResult
    func onQueryChange(_ query: String) -> Task<Void, Never> {
        self.query = query
        searchTask?.cancel()
        let task = Task { [searchDebounce] in
            try? await Task.sleep(for: searchDebounce)
            guard !Task.isCancelled else { return }
            await loadPage(1)
        }
        searchTask = task
        return task
    }

    func onCategoryChange(_ category: String) async {
        guard category != self.category else { return }
        self.category = category
        await load()
    }

    func onJoinTap(_ community: Community) async {
        guard !pendingJoinIds.contains(community.id) else { return }
        if community.isJoined {
            communityToLeave = community
        } else {
            await setJoined(community, joined: true)
        }
    }

    func onLeaveConfirmed() async {
        guard let community = communityToLeave else { return }
        communityToLeave = nil
        await setJoined(community, joined: false)
    }

    func onLeaveDismissed() {
        communityToLeave = nil
    }

    func onCommunityCreated(_ community: Community) {
        guard appliedCategory == nil, appliedSearch == nil else { return }
        communities = [community] + communities.filter { $0.id != community.id }
    }

    func onCommunityRemoved(_ communityId: Int) {
        communities.removeAll { $0.id == communityId }
    }

    private func setJoined(_ community: Community, joined: Bool) async {
        pendingJoinIds.insert(community.id)
        defer { pendingJoinIds.remove(community.id) }
        replaceJoined(community.id, isJoined: joined)
        do {
            try await repository.setJoined(communityId: community.id, isJoined: joined)
            communityUpdates.publish(communityId: community.id, isJoined: joined)
        } catch {
            replaceJoined(community.id, isJoined: !joined)
            toastMessage = joined
                ? "Couldn't join this community. Please try again."
                : "Couldn't leave this community. Please try again."
        }
    }

    private func replaceJoined(_ communityId: Int, isJoined: Bool) {
        guard let index = communities.firstIndex(where: { $0.id == communityId }) else { return }
        communities[index].isJoined = isJoined
    }

    private func loadPage(_ page: Int) async {
        pageTask?.cancel()
        if page == 1 {
            communities = []
            currentPage = 0
            lastPage = 1
            isLoading = true
            isLoadingMore = false
        } else {
            isLoadingMore = true
        }
        hasError = false
        loadMoreFailed = false
        if page == 1 {
            let trimmed = query.trimmingCharacters(in: .whitespaces)
            appliedCategory = category == Self.allCategory ? nil : category
            appliedSearch = trimmed.isEmpty ? nil : trimmed
        }
        let task = Task { await fetchPage(page) }
        pageTask = task
        await task.value
    }

    private func fetchPage(_ page: Int) async {
        do {
            let result = try await repository.fetchCommunities(
                category: appliedCategory,
                search: appliedSearch,
                page: page,
                perPage: Self.pageSize
            )
            guard !Task.isCancelled else { return }
            communities = page == 1 ? result.items : communities + result.items
            currentPage = result.currentPage
            lastPage = result.lastPage
        } catch {
            guard !Task.isCancelled else { return }
            hasError = page == 1
            loadMoreFailed = page > 1
        }
        isLoading = false
        isLoadingMore = false
    }
}
