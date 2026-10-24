import Foundation

@MainActor
@Observable
final class CreateTopicViewModel {
    static let titleMin = 3
    static let titleLimit = 120
    static let bodyMin = 10
    static let bodyLimit = 2000

    private(set) var community: Community?
    private(set) var title = ""
    private(set) var body = ""
    private(set) var communities: [Community] = []
    private(set) var isLoadingCommunities = false
    private(set) var communitiesFailed = false
    private(set) var isSubmitted = false
    private(set) var isSubmitting = false
    private(set) var createdPost: CommunityPost?
    var toastMessage: String?

    let isCommunityLocked: Bool

    private let repository: CommunityRepository
    private let postUpdates: PostUpdates

    init(community: Community? = nil, repository: CommunityRepository, postUpdates: PostUpdates) {
        self.community = community
        self.repository = repository
        self.postUpdates = postUpdates
        isCommunityLocked = community != nil
    }

    var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedBody: String {
        body.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var hasContent: Bool {
        !trimmedTitle.isEmpty || !trimmedBody.isEmpty
    }

    var titleRemaining: Int {
        Self.titleLimit - trimmedTitle.count
    }

    var communityError: String? {
        isSubmitted ? Self.communityError(for: community) : nil
    }

    var titleError: String? {
        isSubmitted ? Self.titleError(for: trimmedTitle) : nil
    }

    var bodyError: String? {
        isSubmitted ? Self.bodyError(for: trimmedBody) : nil
    }

    var canSubmit: Bool {
        Self.communityError(for: community) == nil && Self.titleError(for: trimmedTitle) == nil
            && Self.bodyError(for: trimmedBody) == nil
    }

    func loadIfNeeded() async {
        guard !isCommunityLocked, !isLoadingCommunities, communities.isEmpty else { return }
        await loadCommunities()
    }

    func retryCommunities() async {
        await loadCommunities()
    }

    func onCommunityChange(_ value: Community) {
        guard !isCommunityLocked else { return }
        community = value
    }

    func onTitleChange(_ value: String) {
        title = value
    }

    func onBodyChange(_ value: String) {
        body = value
    }

    func submit() async -> CommunityPost? {
        guard !isSubmitting, createdPost == nil else { return nil }
        isSubmitted = true
        guard canSubmit, let community else { return nil }

        isSubmitting = true
        toastMessage = nil
        defer { isSubmitting = false }

        do {
            let created = try await repository.createPost(
                title: trimmedTitle,
                description: trimmedBody,
                communityId: community.id
            )
            createdPost = created
            postUpdates.publishCreated(created)
            return created
        } catch {
            toastMessage = error.userMessage()
            return nil
        }
    }

    private func loadCommunities() async {
        isLoadingCommunities = true
        communitiesFailed = false
        defer { isLoadingCommunities = false }
        do {
            communities = try await repository.fetchJoinedCommunities()
        } catch {
            communitiesFailed = true
        }
    }

    private static func communityError(for community: Community?) -> String? {
        community == nil ? "Pick a community" : nil
    }

    private static func titleError(for title: String) -> String? {
        if title.isEmpty { return "Title is required" }
        if title.count < titleMin { return "At least \(titleMin) characters" }
        if title.count > titleLimit { return "Title must be at most \(titleLimit) characters" }
        return nil
    }

    private static func bodyError(for body: String) -> String? {
        if body.isEmpty { return "Body is required" }
        if body.count < bodyMin { return "At least \(bodyMin) characters" }
        if body.count > bodyLimit { return "Body must be at most \(bodyLimit) characters" }
        return nil
    }
}
