import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct PostCommentThreadsTests {
    private static let comments = CommunityMockData.comments
    private static let thread = CommunityMockData.comments[0]
    private static let reply = CommunityMockData.comments[0].replies[0]

    @Test func findCommentFindsThreadsAndReplies() {
        #expect(Self.comments.findComment(id: Self.thread.id)?.id == Self.thread.id)
        #expect(Self.comments.findComment(id: Self.reply.id)?.id == Self.reply.id)
        #expect(Self.comments.findComment(id: -1) == nil)
    }

    @Test func replacingCommentChangesOnlyTheMatchingReply() {
        let updated = Self.comments.replacingComment(id: Self.reply.id) { $0.likes = 99 }

        #expect(updated.findComment(id: Self.reply.id)?.likes == 99)
        #expect(updated.findComment(id: Self.thread.id)?.likes == Self.thread.likes)
        #expect(updated.dropFirst().map(\.likes) == Self.comments.dropFirst().map(\.likes))
    }

    @Test func addingReplyToAReplyAppendsItToTheRootThread() {
        let created = PostComment(id: 999, author: "@you", timeAgo: "now", content: "New", likes: 0)

        let updated = Self.comments.addingReply(to: Self.reply.id, created)

        #expect(updated[0].replies.last?.id == created.id)
        #expect(updated[0].replies.count == Self.thread.replies.count + 1)
        #expect(updated.dropFirst().map(\.replies.count) == Self.comments.dropFirst().map(\.replies.count))
    }
}
