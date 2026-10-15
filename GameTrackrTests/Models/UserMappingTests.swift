import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct UserMappingTests {
    private static let bio = "Platinum hunter"
    private static let fullBody = #"""
    {"id":1,"name":"Player One","email":"player@example.com","bio":"\#(bio)",\#
    "visibility":"private","created_at":"2026-06-25T10:00:00.000000Z"}
    """#
    private static let minimalBody = #"{"id":1,"name":"Player One","email":"player@example.com"}"#

    @Test func mapsBioVisibilityAndJoinDate() throws {
        let user = try decode(Self.fullBody)

        #expect(user.bio == Self.bio)
        #expect(user.visibility == .privateProfile)
        let components = try #require(user.createdAt).formatted(.iso8601.year().month().day())
        #expect(components == "2026-06-25")
    }

    @Test func missingFieldsFallBackToNoBioPublicAndNoJoinDate() throws {
        let user = try decode(Self.minimalBody)

        #expect(user.bio == nil)
        #expect(user.visibility == .publicProfile)
        #expect(user.createdAt == nil)
    }

    private func decode(_ json: String) throws -> User {
        try JSONDecoder().decode(User.self, from: Data(json.utf8))
    }
}
