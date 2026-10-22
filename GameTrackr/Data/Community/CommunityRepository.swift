protocol CommunityRepository: Sendable {
    func fetchCommunities(page: Int, perPage: Int, search: String?) async throws -> Page<Community>
    func fetchCommunity(id: Int) async throws -> Community
    func fetchJoinedCommunities() async throws -> [Community]
    func fetchCommunityMembers(id: Int) async throws -> [CommunityMember]
    func createCommunity(title: String, description: String) async throws -> Community
    func deleteCommunity(id: Int) async throws
    func joinCommunity(id: Int) async throws
    func leaveCommunity(id: Int) async throws
    func fetchPosts(page: Int, perPage: Int, communityId: Int?) async throws -> Page<CommunityPost>
    func fetchPostComments(postId: Int) async throws -> [PostComment]
    func createPost(title: String, description: String, communityId: Int) async throws -> CommunityPost
    func deletePost(id: Int) async throws
    func togglePostLike(id: Int) async throws -> LikeStatus
    func addComment(postId: Int, comment: String) async throws -> PostComment
    func replyToComment(postId: Int, commentId: Int, comment: String) async throws -> PostComment
    func toggleCommentLike(postId: Int, commentId: Int) async throws -> LikeStatus
}
