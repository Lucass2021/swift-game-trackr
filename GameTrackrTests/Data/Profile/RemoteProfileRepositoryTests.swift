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
        private static let colorsBody = #"""
        {"message":"Profile colors fetched successfully.",\#
        "data":[{"key":"\#(colorKey)","name":"\#(colorName)","hex":"\#(colorHex)"}]}
        """#
        private static let updateBody = #"""
        {"message":"Profile updated successfully.",\#
        "user":{"id":1,"name":"\#(name)","username":"\#(username)","email":"player@example.com",\#
        "profile_color":"\#(colorHex)"}}
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

            let user = try await repository.updateProfile(
                name: Self.name,
                username: Self.username,
                profileColor: Self.colorHex
            )

            #expect(user.name == Self.name)
            #expect(user.username == Self.username)
            #expect(user.profileColor == Self.colorHex)
        }
    }
}
