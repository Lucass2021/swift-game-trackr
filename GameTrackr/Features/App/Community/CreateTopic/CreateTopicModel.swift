import SwiftUI

@MainActor
@Observable
final class CreateTopicModel {
    static let titleLimit = 120
    static let bodyLimit = 2000

    var community: Community?
    var title = ""
    var body = ""
    private(set) var hasAttemptedSubmit = false

    let isCommunityLocked: Bool

    init(community: Community? = nil) {
        self.community = community
        isCommunityLocked = community != nil
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedBody: String {
        body.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var communityError: String? {
        community == nil ? "Pick a community" : nil
    }

    var titleError: String? {
        if trimmedTitle.isEmpty { return "Title is required" }
        if trimmedTitle.count < 3 { return "Title must be at least 3 characters" }
        if title.count > Self.titleLimit { return "Title must be under \(Self.titleLimit) characters" }
        return nil
    }

    var bodyError: String? {
        if trimmedBody.isEmpty { return "Body is required" }
        if trimmedBody.count < 10 { return "Body must be at least 10 characters" }
        if body.count > Self.bodyLimit { return "Body must be under \(Self.bodyLimit) characters" }
        return nil
    }

    var canSubmit: Bool {
        communityError == nil && titleError == nil && bodyError == nil
    }

    var hasContent: Bool {
        !trimmedTitle.isEmpty || !trimmedBody.isEmpty
    }

    var titleRemaining: Int {
        Self.titleLimit - title.count
    }

    func visibleError(_ error: String?) -> String? {
        hasAttemptedSubmit ? error : nil
    }

    func submit() -> CommunityPost? {
        hasAttemptedSubmit = true
        guard canSubmit, let community else { return nil }

        return CommunityPost(
            author: "You",
            timeAgo: "now",
            communityName: community.name,
            title: trimmedTitle,
            preview: trimmedBody,
            likes: 0,
            comments: 0,
            hasMedia: false,
            avatarStart: .coverVioletStart,
            avatarEnd: .coverVioletEnd,
            mediaStart: .coverVioletStart,
            mediaEnd: .coverVioletEnd
        )
    }
}
