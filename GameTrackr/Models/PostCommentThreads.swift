import Foundation

extension [PostComment] {
    nonisolated func findComment(id: Int) -> PostComment? {
        flatMap { [$0] + $0.replies }.first { $0.id == id }
    }

    nonisolated func replacingComment(id: Int, _ transform: (inout PostComment) -> Void) -> [PostComment] {
        map { thread in
            var updated = thread
            if updated.id == id { transform(&updated) }
            updated.replies = updated.replies.map { reply in
                var reply = reply
                if reply.id == id { transform(&reply) }
                return reply
            }
            return updated
        }
    }

    nonisolated func addingReply(to targetId: Int, _ reply: PostComment) -> [PostComment] {
        map { thread in
            guard thread.id == targetId || thread.replies.contains(where: { $0.id == targetId }) else { return thread }
            var updated = thread
            updated.replies.append(reply)
            return updated
        }
    }
}
