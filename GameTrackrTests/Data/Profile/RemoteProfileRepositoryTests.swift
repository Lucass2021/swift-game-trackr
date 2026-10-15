import Foundation
import Testing
@testable import GameTrackr

extension RepositoryTests {
    @MainActor
    struct RemoteProfileRepositoryTests {
        private static let httpOK = 200
        private static let colorKey = "purple"
        private static let colorName = "Purple"
        private static let colorHex = "#8B5CF6"
        private static let name = "Player One"
        private static let username = "player_one"
        private static let bio = "Platinum hunter"
        private static let colorsBody = #"""
        {"message":"Profile colors fetched successfully.",\#
        "data":[{"key":"\#(colorKey)","name":"\#(colorName)","hex":"\#(colorHex)"}]}
        """#
        private static let updateBody = #"""
        {"message":"Profile updated successfully.",\#
        "user":{"id":1,"name":"\#(name)","username":"\#(username)","email":"player@example.com",\#
        "profile_color":"\#(colorHex)","bio":"\#(bio)","visibility":"private"}}
        """#

        private let repository: RemoteProfileRepository

        init() {
            let apiClient = APIClient(session: StubURLProtocol.makeSession(), tokenStore: FakeTokenStore())
            repository = RemoteProfileRepository(apiClient: apiClient)
        }

        @Test func fetchColorsMapsTheAPIColorsToProfileColors() async throws {
            StubURLProtocol.stub = .init(statusCode: Self.httpOK, body: Self.colorsBody)

            let colors = try await repository.fetchColors()

            #expect(colors == [ProfileColor(key: Self.colorKey, name: Self.colorName, hex: Self.colorHex)])
        }

        @Test func updateProfileReturnsTheUpdatedUser() async throws {
            StubURLProtocol.stub = .init(statusCode: Self.httpOK, body: Self.updateBody)

            let user = try await updateProfile()

            #expect(user.name == Self.name)
            #expect(user.username == Self.username)
            #expect(user.profileColor == Self.colorHex)
            #expect(user.bio == Self.bio)
            #expect(user.visibility == .privateProfile)
        }

        @Test func updateProfileSendsBioAndVisibility() async throws {
            StubURLProtocol.stub = .init(statusCode: Self.httpOK, body: Self.updateBody)

            _ = try await updateProfile()

            let body = try #require(StubURLProtocol.lastRequestBody.flatMap { String(bytes: $0, encoding: .utf8) })
            #expect(body.contains(#""bio":"\#(Self.bio)""#))
            #expect(body.contains(#""visibility":"private""#))
        }

        private func updateProfile() async throws -> User {
            try await repository.updateProfile(
                name: Self.name,
                username: Self.username,
                profileColor: Self.colorHex,
                bio: Self.bio,
                visibility: .privateProfile
            )
        }
    }
}
