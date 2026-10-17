import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct NotificationsViewModelTests {
    private static let overlapLatency: Duration = .milliseconds(50)
    private static let firstPageIds = [1, 2, 3, 4]
    private static let mentionIds = [5]

    @Test func loadShowsTheFirstPageGroupedBySection() async {
        let viewModel = NotificationsViewModel(repository: FakeNotificationsRepository(latency: .zero))

        await viewModel.loadIfNeeded()

        #expect(viewModel.items.map(\.id) == Self.firstPageIds)
        #expect(viewModel.sections.map(\.section) == [.new, .today])
        #expect(viewModel.sections.first?.items.map(\.id) == [1, 2, 3])
        #expect(viewModel.canLoadMore)
    }

    @Test func loadFailureShowsTheErrorStateInsteadOfLoadingForever() async {
        let viewModel = NotificationsViewModel(repository: FakeNotificationsRepository(
            failure: APIError.networkFailure,
            latency: .zero
        ))

        await viewModel.loadIfNeeded()

        #expect(viewModel.hasError)
        #expect(!viewModel.isLoading)
    }

    @Test func retryAfterAFailureShowsTheNotifications() async {
        let repository = FakeNotificationsRepository(failure: APIError.networkFailure, latency: .zero)
        let viewModel = NotificationsViewModel(repository: repository)
        await viewModel.loadIfNeeded()

        await repository.setFailure(nil)
        await viewModel.load()

        #expect(viewModel.items.map(\.id) == Self.firstPageIds)
        #expect(!viewModel.hasError)
    }

    @Test func returningToTheScreenKeepsTheNotificationsWithoutFetchingAgain() async {
        let repository = FakeNotificationsRepository(latency: .zero)
        let viewModel = NotificationsViewModel(repository: repository)
        await viewModel.loadIfNeeded()

        await viewModel.loadIfNeeded()

        #expect(await repository.fetchCount == 1)
        #expect(viewModel.items.map(\.id) == Self.firstPageIds)
    }

    @Test func theMentionsFilterFindsMentionsBeyondTheFirstPage() async {
        let viewModel = NotificationsViewModel(repository: FakeNotificationsRepository(latency: .zero))
        await viewModel.loadIfNeeded()

        await viewModel.onFilterChange(.mentions)

        #expect(viewModel.items.map(\.id) == Self.mentionIds)
    }

    @Test func aFilterChangeReplacesTheLoadInFlight() async {
        let repository = FakeNotificationsRepository(latency: Self.overlapLatency)
        let viewModel = NotificationsViewModel(repository: repository)

        let loading = Task { await viewModel.loadIfNeeded() }
        while await repository.fetchCount == 0 {
            await Task.yield()
        }
        await viewModel.onFilterChange(.mentions)
        await loading.value

        #expect(viewModel.items.map(\.id) == Self.mentionIds)
    }

    @Test func aLoadMoreFailureKeepsTheNotificationsAndStopsUntilRetried() async {
        let repository = FakeNotificationsRepository(latency: .zero)
        let viewModel = NotificationsViewModel(repository: repository)
        await viewModel.loadIfNeeded()

        await repository.setFailure(APIError.networkFailure)
        await viewModel.loadMore()

        #expect(viewModel.loadMoreFailed)
        #expect(!viewModel.canLoadMore)
        #expect(viewModel.items.map(\.id) == Self.firstPageIds)

        await repository.setFailure(nil)
        await viewModel.loadMore()

        #expect(!viewModel.loadMoreFailed)
        #expect(viewModel.items.map(\.id) == Array(1 ... 8))
    }
}
