import Foundation

struct NotificationSectionGroup: Identifiable {
    let section: NotificationSection
    let items: [NotificationItem]

    var id: NotificationSection {
        section
    }
}

@MainActor
@Observable
final class NotificationsViewModel {
    static let pageSize = 4

    private(set) var items: [NotificationItem] = []
    private(set) var filter: NotificationFilter = .all
    private(set) var currentPage = 0
    private(set) var lastPage = 1
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var hasError = false
    private(set) var loadMoreFailed = false
    var errorMessage: String?

    var canLoadMore: Bool {
        (1 ..< lastPage).contains(currentPage) && !isLoading && !isLoadingMore && !loadMoreFailed
    }

    var sections: [NotificationSectionGroup] {
        NotificationSection.allCases.compactMap { section in
            let sectionItems = items.filter { $0.section == section }
            return sectionItems.isEmpty ? nil : NotificationSectionGroup(section: section, items: sectionItems)
        }
    }

    private let repository: NotificationsRepository
    private var listTask: Task<Void, Never>?
    private var pendingFriendRequestIds: Set<Int> = []

    init(repository: NotificationsRepository) {
        self.repository = repository
    }

    func loadIfNeeded() async {
        guard currentPage == 0, !isLoading else { return }
        await load()
    }

    func load() async {
        await loadPage(1)
    }

    func loadMore() async {
        guard currentPage > 0, currentPage < lastPage, !isLoading, !isLoadingMore else { return }
        await loadPage(currentPage + 1)
    }

    func onFilterChange(_ filter: NotificationFilter) async {
        guard filter != self.filter else { return }
        self.filter = filter
        await loadPage(1)
    }

    func onMarkAllRead() async {
        await runAction(errorMessage: "Couldn't mark notifications as read. Please try again.") {
            try await repository.markAllAsRead()
        } onSuccess: {
            if filter == .unread {
                showNoNotifications()
            } else {
                for index in items.indices {
                    items[index].unread = false
                }
            }
        }
    }

    func onClearAll() async {
        await runAction(errorMessage: "Couldn't clear notifications. Please try again.") {
            try await repository.clearNotifications()
        } onSuccess: {
            showNoNotifications()
        }
    }

    func onAcceptFriendRequest(_ id: Int) async {
        await respondToFriendRequest(id, accept: true)
    }

    func onDeclineFriendRequest(_ id: Int) async {
        await respondToFriendRequest(id, accept: false)
    }

    private func respondToFriendRequest(_ id: Int, accept: Bool) async {
        guard pendingFriendRequestIds.insert(id).inserted else { return }
        await runAction(errorMessage: "Couldn't answer the friend request. Please try again.") {
            defer { pendingFriendRequestIds.remove(id) }
            try await repository.respondToFriendRequest(id: id, accept: accept)
        } onSuccess: {
            await removeAnsweredFriendRequest(id)
        }
    }

    private func removeAnsweredFriendRequest(_ id: Int) async {
        if currentPage < lastPage {
            await load()
        } else {
            items.removeAll { $0.id == id }
        }
    }

    private func runAction(
        errorMessage: String,
        action: () async throws -> Void,
        onSuccess: () async -> Void
    ) async {
        do {
            try await action()
            await onSuccess()
        } catch {
            self.errorMessage = errorMessage
        }
    }

    private func showNoNotifications() {
        listTask?.cancel()
        let page = max(currentPage, 1)
        items = []
        currentPage = page
        lastPage = page
        isLoading = false
        isLoadingMore = false
        loadMoreFailed = false
    }

    private func loadPage(_ page: Int) async {
        listTask?.cancel()
        if page == 1 {
            items = []
            currentPage = 0
            lastPage = 1
            isLoading = true
            isLoadingMore = false
        } else {
            isLoadingMore = true
        }
        hasError = false
        loadMoreFailed = false
        let task = Task { await fetch(page: page, filter: filter) }
        listTask = task
        await task.value
    }

    private func fetch(page: Int, filter: NotificationFilter) async {
        do {
            let result = try await repository.fetchNotifications(
                filter: filter,
                page: page,
                perPage: Self.pageSize
            )
            guard !Task.isCancelled else { return }
            items = page == 1 ? result.items : items + result.items
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
