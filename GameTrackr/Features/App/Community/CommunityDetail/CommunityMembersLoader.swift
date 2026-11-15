import Foundation

@MainActor
@Observable
final class CommunityMembersLoader {
    private(set) var members: [CommunityMember] = []
    private(set) var hasFailed = false

    private let repository: CommunityRepository
    private let communityId: Int
    private var task: Task<Void, Never>?

    init(repository: CommunityRepository, communityId: Int) {
        self.repository = repository
        self.communityId = communityId
    }

    func load() async {
        task?.cancel()
        hasFailed = false
        let task = Task { await fetch() }
        self.task = task
        await task.value
    }

    private func fetch() async {
        do {
            let result = try await repository.fetchCommunityMembers(id: communityId)
            guard !Task.isCancelled else { return }
            members = result
        } catch {
            guard !Task.isCancelled else { return }
            hasFailed = true
        }
    }
}
