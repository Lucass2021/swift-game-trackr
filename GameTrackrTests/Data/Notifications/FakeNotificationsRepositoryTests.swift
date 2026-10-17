import Foundation
import Testing
@testable import GameTrackr

struct FakeNotificationsRepositoryTests {
    private static let perPage = 4

    @Test func theUnreadFilterReturnsOnlyUnreadNotifications() async throws {
        let page = try await FakeNotificationsRepository(latency: .zero)
            .fetchNotifications(filter: .unread, page: 1, perPage: Self.perPage)

        #expect(page.items.map(\.id) == [1, 2, 3])
    }

    @Test func clearingRemovesTheNotificationsThatWereNotLoadedYet() async throws {
        let repository = FakeNotificationsRepository(latency: .zero)

        try await repository.clearNotifications()
        let page = try await repository.fetchNotifications(filter: .all, page: 2, perPage: Self.perPage)

        #expect(page.items.isEmpty)
        #expect(page.total == 0)
    }

    @Test func answeringAnUnknownFriendRequestFailsWithNotFound() async {
        let repository = FakeNotificationsRepository(latency: .zero)

        do {
            try await repository.respondToFriendRequest(id: 2, accept: true)
            Issue.record("Expected a not found error")
        } catch APIError.notFound {
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}
