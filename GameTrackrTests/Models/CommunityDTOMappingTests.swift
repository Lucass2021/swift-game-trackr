import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct CommunityDTOMappingTests {
    private func community(createdAt: String?) throws -> Community {
        let createdField = createdAt.map { "\"created_at\": \"\($0)\"," } ?? ""
        let json = """
        {\(createdField) "id": 1, "title": "Soulsborne", "slug": "soulsborne", "author_id": 1}
        """
        let dto = try JSONDecoder().decode(CommunityDTO.self, from: Data(json.utf8))
        return Community(dto: dto)
    }

    @Test func theCreatedMonthComesFromTheAPICreationDate() throws {
        #expect(try community(createdAt: "2026-06-25T09:27:09.000000Z").createdMonth == "June 2026")
    }

    @Test func aMissingOrInvalidCreationDateLeavesTheCreatedMonthEmpty() throws {
        #expect(try community(createdAt: nil).createdMonth == nil)
        #expect(try community(createdAt: "not a date").createdMonth == nil)
        #expect(try community(createdAt: "2026-13-45T00:00:00.000000Z").createdMonth == nil)
    }
}
