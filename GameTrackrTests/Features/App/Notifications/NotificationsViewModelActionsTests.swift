import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct NotificationsViewModelActionsTests {
    private static let friendRequestId = 1
    private static let overlapLatency: Duration = .milliseconds(50)

    private let repository = FakeNotificationsRepository(latency: .zero)
    private let viewModel: NotificationsViewModel

    init() {
        viewModel = NotificationsViewModel(repository: repository)
    }

    private func loadFirstPage(_ filter: NotificationFilter = .all) async {
        await viewModel.loadIfNeeded()
        await viewModel.onFilterChange(filter)
    }

    @Test func markAllReadClearsTheUnreadState() async {
        await loadFirstPage()

        await viewModel.onMarkAllRead()

        #expect(!viewModel.items.isEmpty)
        #expect(!viewModel.items.contains { $0.unread })
        let storedItems = await repository.storedItems
        #expect(!storedItems.contains { $0.unread })
    }

    @Test func markAllReadWithTheUnreadFilterLeavesNothingToShow() async {
        await loadFirstPage(.unread)

        await viewModel.onMarkAllRead()

        #expect(viewModel.items.isEmpty)
        #expect(!viewModel.canLoadMore)
    }

    @Test func aMarkAllReadFailureKeepsTheNotificationsAndShowsAnError() async {
        await loadFirstPage()

        await repository.setFailure(APIError.networkFailure)
        await viewModel.onMarkAllRead()

        #expect(viewModel.errorMessage == "Couldn't mark notifications as read. Please try again.")
        #expect(viewModel.items.contains { $0.unread })
    }

    @Test func clearAllRemovesEveryNotificationIncludingTheOnesNotLoadedYet() async {
        await loadFirstPage()

        await viewModel.onClearAll()

        #expect(viewModel.items.isEmpty)
        #expect(!viewModel.canLoadMore)
        #expect(await repository.storedItems.isEmpty)
    }

    @Test func aClearAllFailureKeepsTheNotificationsAndShowsAnError() async {
        await loadFirstPage()

        await repository.setFailure(APIError.networkFailure)
        await viewModel.onClearAll()

        #expect(viewModel.errorMessage == "Couldn't clear notifications. Please try again.")
        #expect(viewModel.items.count == 4)
    }

    @Test func acceptingAFriendRequestRemovesIt() async {
        await loadFirstPage()

        await viewModel.onAcceptFriendRequest(Self.friendRequestId)

        #expect(!viewModel.items.contains { $0.id == Self.friendRequestId })
        let storedItems = await repository.storedItems
        #expect(!storedItems.contains { $0.id == Self.friendRequestId })
    }

    @Test func aDeclineFailureKeepsTheFriendRequestAndShowsAnError() async {
        await loadFirstPage()

        await repository.setFailure(APIError.networkFailure)
        await viewModel.onDeclineFriendRequest(Self.friendRequestId)

        #expect(viewModel.errorMessage == "Couldn't answer the friend request. Please try again.")
        #expect(viewModel.items.contains { $0.id == Self.friendRequestId })
    }

    @Test func answeringAFriendRequestDoesNotSkipTheNextPage() async {
        await loadFirstPage()

        await viewModel.onAcceptFriendRequest(Self.friendRequestId)
        await viewModel.loadMore()

        #expect(viewModel.items.map(\.id) == Array(2 ... 8))
    }

    @Test func aDoubleTapOnAcceptAnswersOnceWithoutAnError() async {
        let repository = FakeNotificationsRepository(latency: Self.overlapLatency)
        let viewModel = NotificationsViewModel(repository: repository)
        await viewModel.loadIfNeeded()

        async let first: Void = viewModel.onAcceptFriendRequest(Self.friendRequestId)
        async let second: Void = viewModel.onAcceptFriendRequest(Self.friendRequestId)
        _ = await (first, second)

        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.items.contains { $0.id == Self.friendRequestId })
    }
}
