import Foundation

@MainActor
@Observable
final class CommunityViewModel {
    private let repository: CommunityRepository

    init(repository: CommunityRepository = RemoteCommunityRepository()) {
        self.repository = repository
    }

    func createCommunity(name: String, description: String) async throws -> Community {
        var created = try await repository.createCommunity(title: name, description: description)
        created.isJoined = true
        created.memberCount = Constants.firstMemberCount
        return created
    }

    func createPost(title: String, body: String, communityId: Int) async -> CommunityPost? {
        try? await repository.createPost(title: title, description: body, communityId: communityId)
    }
}

private enum Constants {
    static let firstMemberCount = 1
}
