import Testing
@testable import GameTrackr

extension RepositoryTests {
    @MainActor
    struct RemoteCommunityRepositoryTests {
        private static let httpOK = 200
        private static let postId = 7
        private static let postTitle = "Best boss fight?"
        private static let currentPage = 1
        private static let lastPage = 3
        private static let perPage = 20
        private static let total = 45
        private static let likes = 12
        private static let postsBody = #"""
        {"data":[{"id":\#(postId),"title":"\#(postTitle)","slug":"best-boss-fight","community_id":1,"author_id":1}],\#
        "current_page":\#(currentPage),"last_page":\#(lastPage),"per_page":\#(perPage),"total":\#(total)}
        """#
        private static let likeBody = #"{"message":"Post liked","is_liked":true,"likes":\#(likes)}"#

        private static let rootCommentId = 1
        private static let replyId = 2
        private static let nestedReplyId = 3
        private static let postWithCommentsBody = #"""
        {"id":\#(postId),"title":"\#(postTitle)","slug":"best-boss-fight","community_id":1,"author_id":1,"comments":[\#
        {"id":\#(rootCommentId),"content":"Root","author_id":1,"post_id":\#(postId)},\#
        {"id":\#(replyId),"content":"Reply","author_id":1,"post_id":\#(postId),"parent_id":\#(rootCommentId)},\#
        {"id":\#(nestedReplyId),"content":"Nested","author_id":1,"post_id":\#(postId),"parent_id":\#(replyId)}]}
        """#

        private let repository: RemoteCommunityRepository

        init() {
            let apiClient = APIClient(session: StubURLProtocol.makeSession(), tokenStore: FakeTokenStore())
            repository = RemoteCommunityRepository(apiClient: apiClient)
        }

        @Test func fetchPostsMapsThePaginatedResponseToAPage() async throws {
            StubURLProtocol.stub = .init(statusCode: Self.httpOK, body: Self.postsBody)

            let page = try await repository.fetchPosts(page: Self.currentPage, perPage: Self.perPage, communityId: nil)

            #expect(page.items.map(\.title) == [Self.postTitle])
            #expect(page.currentPage == Self.currentPage)
            #expect(page.lastPage == Self.lastPage)
            #expect(page.total == Self.total)
        }

        @Test func fetchPostCommentsNestsRepliesUnderTheirRootComment() async throws {
            StubURLProtocol.stub = .init(statusCode: Self.httpOK, body: Self.postWithCommentsBody)

            let comments = try await repository.fetchPostComments(postId: Self.postId)

            #expect(comments.map(\.id) == [Self.rootCommentId])
            #expect(comments.first?.replies.map(\.id) == [Self.replyId, Self.nestedReplyId])
        }

        @Test func togglePostLikeReturnsTheLikeStatusFromTheAPI() async throws {
            StubURLProtocol.stub = .init(statusCode: Self.httpOK, body: Self.likeBody)

            let status = try await repository.togglePostLike(id: Self.postId)

            #expect(status == LikeStatus(isLiked: true, likes: Self.likes))
        }
    }
}
