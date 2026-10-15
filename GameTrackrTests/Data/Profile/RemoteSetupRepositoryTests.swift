import Foundation
import Testing
@testable import GameTrackr

extension RepositoryTests {
    @MainActor
    struct RemoteSetupRepositoryTests {
        private static let httpOK = 200
        private static let httpCreated = 201
        private static let setupId = 5
        private static let imageId = 9
        private static let title = "Main Battle Station"
        private static let setupDescription = "RTX 4090"
        private static let fileName = "desk.jpg"
        private static let imageURL = "http://localhost:8000/storage/9/desk.jpg"
        private static let setupJSON = #"""
        {"id":\#(setupId),"user_id":1,"title":"\#(title)","description":null,\#
        "images":[{"id":\#(imageId),"url":"\#(imageURL)","name":"desk","file_name":"\#(fileName)",\#
        "mime_type":"image/jpeg","size":3}],"media":[]}
        """#
        private static let setupsBody = #"{"message":"Setups retrieved successfully.","data":[\#(setupJSON)]}"#
        private static let setupBody = #"{"message":"Setup created successfully.","data":\#(setupJSON)}"#
        private static let deleteBody = #"{"message":"Setup deleted successfully."}"#

        private let repository: RemoteSetupRepository

        init() {
            let apiClient = APIClient(session: StubURLProtocol.makeSession(), tokenStore: FakeTokenStore())
            repository = RemoteSetupRepository(apiClient: apiClient)
        }

        @Test func fetchSetupsMapsImagesAndPicksThePaletteFromTheId() async throws {
            StubURLProtocol.stub = .init(statusCode: Self.httpOK, body: Self.setupsBody)

            let setups = try await repository.fetchSetups()

            let setup = try #require(setups.first)
            #expect(setups.count == 1)
            #expect(setup.id == Self.setupId)
            #expect(setup.title == Self.title)
            #expect(setup.description.isEmpty)
            #expect(setup.images == [SetupImage(id: Self.imageId, url: Self.imageURL)])
            #expect(setup.palette == .forId(Self.setupId))
        }

        @Test func createSetupSendsTitleDescriptionAndImagesAsMultipart() async throws {
            StubURLProtocol.stub = .init(statusCode: Self.httpCreated, body: Self.setupBody)

            _ = try await repository.createSetup(
                title: Self.title,
                description: Self.setupDescription,
                images: [upload()]
            )

            let request = try #require(StubURLProtocol.lastRequest)
            let body = try requestBody()
            #expect(request.httpMethod == "POST")
            #expect(request.url?.path().hasSuffix("/profile/setups") == true)
            #expect(request.value(forHTTPHeaderField: "Content-Type")?.hasPrefix("multipart/form-data") == true)
            #expect(body.contains(#"name="title""#))
            #expect(body.contains(Self.title))
            #expect(body.contains(Self.setupDescription))
            #expect(body.contains(#"name="images[]"; filename="\#(Self.fileName)""#))
        }

        @Test func updateSetupPostsNewImagesAndRemovedImageIds() async throws {
            StubURLProtocol.stub = .init(statusCode: Self.httpOK, body: Self.setupBody)

            _ = try await repository.updateSetup(
                id: Self.setupId,
                title: Self.title,
                description: Self.setupDescription,
                newImages: [upload()],
                removedImageIds: [Self.imageId]
            )

            let request = try #require(StubURLProtocol.lastRequest)
            let body = try requestBody()
            #expect(request.httpMethod == "POST")
            #expect(request.url?.path().hasSuffix("/profile/setups/\(Self.setupId)") == true)
            #expect(body.contains(#"name="remove_image_ids[]""#))
            #expect(body.contains(#"name="images[]"; filename="\#(Self.fileName)""#))
        }

        @Test func deleteSetupCallsTheSetupEndpoint() async throws {
            StubURLProtocol.stub = .init(statusCode: Self.httpOK, body: Self.deleteBody)

            try await repository.deleteSetup(id: Self.setupId)

            let request = try #require(StubURLProtocol.lastRequest)
            #expect(request.httpMethod == "DELETE")
            #expect(request.url?.path().hasSuffix("/profile/setups/\(Self.setupId)") == true)
        }

        private func upload() -> SetupImageUpload {
            SetupImageUpload(data: Data([1, 2, 3]), fileName: Self.fileName, mimeType: "image/jpeg")
        }

        private func requestBody() throws -> String {
            try #require(StubURLProtocol.lastRequestBody.flatMap { String(bytes: $0, encoding: .utf8) })
        }
    }
}
