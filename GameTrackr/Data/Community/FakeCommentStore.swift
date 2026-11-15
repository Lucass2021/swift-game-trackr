nonisolated struct FakeCommentStore {
    private(set) var all: [PostComment]

    init(_ comments: [PostComment]) {
        all = comments
    }

    func find(_ id: Int) -> PostComment? {
        all.findComment(id: id)
    }

    mutating func add(_ content: String) -> PostComment {
        let created = newComment(content)
        all.append(created)
        return created
    }

    mutating func reply(to parentId: Int, _ content: String) -> PostComment? {
        guard find(parentId) != nil else { return nil }
        let created = newComment(content)
        all = all.addingReply(to: parentId, created)
        return created
    }

    mutating func toggleLike(_ id: Int) -> LikeStatus? {
        guard let current = find(id) else { return nil }
        let status = LikeStatus(isLiked: !current.isLiked, likes: current.likes + (current.isLiked ? -1 : 1))
        all = all.replacingComment(id: id) { comment in
            comment.isLiked = status.isLiked
            comment.likes = status.likes
        }
        return status
    }

    private func newComment(_ content: String) -> PostComment {
        let nextId = (all.flatMap { [$0] + $0.replies }.map(\.id).max() ?? 0) + 1
        return PostComment(id: nextId, author: "@you", timeAgo: "now", content: content, likes: 0)
    }
}
