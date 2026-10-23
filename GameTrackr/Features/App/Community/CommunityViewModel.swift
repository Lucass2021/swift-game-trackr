import Foundation

@MainActor
@Observable
final class CommunityViewModel {
    private let repository: CommunityRepository

    init(repository: CommunityRepository = RemoteCommunityRepository()) {
        self.repository = repository
    }

    func createPost(title: String, body: String, communityId: Int) async -> CommunityPost? {
        try? await repository.createPost(title: title, description: body, communityId: communityId)
    }
}
