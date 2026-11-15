import Testing
@testable import GameTrackr

@MainActor
struct FakeCommunityRepositoryTests {
    private static let postId = 1
    private static let communityId = 1
    private static let missingCommentId = 9999

    @Test func concurrentCommentsGetDistinctIds() async throws {
        let repository = FakeCommunityRepository(latency: .zero)

        async let first = repository.addComment(postId: Self.postId, comment: "First")
        async let second = repository.addComment(postId: Self.postId, comment: "Second")
        let ids = try await [first.id, second.id]

        #expect(Set(ids).count == ids.count)
    }

    @Test func concurrentPostsGetDistinctIds() async throws {
        let repository = FakeCommunityRepository(latency: .zero)

        async let first = repository.createPost(title: "First", description: "Body", communityId: Self.communityId)
        async let second = repository.createPost(title: "Second", description: "Body", communityId: Self.communityId)
        let ids = try await [first.id, second.id]

        #expect(Set(ids).count == ids.count)
    }

    @Test func concurrentCommunitiesGetDistinctIds() async throws {
        let repository = FakeCommunityRepository(latency: .zero)

        async let first = repository.createCommunity(title: "First", description: "About")
        async let second = repository.createCommunity(title: "Second", description: "About")
        let ids = try await [first.id, second.id]

        #expect(Set(ids).count == ids.count)
    }

    @Test func concurrentRepliesGetDistinctIds() async throws {
        let repository = FakeCommunityRepository(latency: .zero)
        let parentId = try #require(CommunityPostMockData.comments.first).id

        async let first = repository.replyToComment(postId: Self.postId, commentId: parentId, comment: "First")
        async let second = repository.replyToComment(postId: Self.postId, commentId: parentId, comment: "Second")
        let ids = try await [first.id, second.id]

        #expect(Set(ids).count == ids.count)
    }

    @Test func replyingToAMissingCommentFailsWithNotFound() async {
        let repository = FakeCommunityRepository(latency: .zero)

        do {
            _ = try await repository.replyToComment(
                postId: Self.postId,
                commentId: Self.missingCommentId,
                comment: "Reply"
            )
            Issue.record("Expected a not found error")
        } catch APIError.notFound {
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}
