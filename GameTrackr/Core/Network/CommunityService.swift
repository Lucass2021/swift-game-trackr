import Foundation

protocol CommunityServicing: Sendable {
    func fetchCommunities(search: String?, perPage: Int?, page: Int?) async throws
        -> PaginatedResponse<CommunityDTO>
    func fetchJoinedCommunities() async throws -> PaginatedResponse<CommunityDTO>
    func fetchCommunity(id: Int) async throws -> CommunityDTO
    func createCommunity(title: String, description: String) async throws -> CommunityDTO
    func deleteCommunity(id: Int) async throws -> MessageResponse
    func join(communityId: Int) async throws -> MessageResponse
    func leave(communityId: Int) async throws -> MessageResponse
    func fetchPosts(search: String?, communityId: Int?, perPage: Int?, page: Int?) async throws
        -> PaginatedResponse<PostDTO>
    func fetchPost(id: Int) async throws -> PostDTO
    func deletePost(id: Int) async throws -> MessageResponse
    func createPost(title: String, description: String?, communityId: Int) async throws -> PostDTO
    func toggleLike(postId: Int) async throws -> LikeResponse
    func addComment(postId: Int, comment: String) async throws -> CommentDTO
    func replyToComment(postId: Int, commentId: Int, comment: String) async throws -> CommentDTO
    func toggleCommentLike(postId: Int, commentId: Int) async throws -> LikeResponse
}

struct CommunityService: CommunityServicing {
    static let live = CommunityService()

    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchCommunities(search: String? = nil, perPage: Int? = nil, page: Int? = nil) async throws
        -> PaginatedResponse<CommunityDTO>
    {
        try await client.request(.communities(search: search, perPage: perPage, page: page))
    }

    func fetchJoinedCommunities() async throws -> PaginatedResponse<CommunityDTO> {
        try await client.request(.joinedCommunities)
    }

    func fetchCommunity(id: Int) async throws -> CommunityDTO {
        try await client.request(.community(id: id))
    }

    func createCommunity(title: String, description: String) async throws -> CommunityDTO {
        let body = CreateCommunityRequest(title: title, description: description)
        let response: CreateCommunityResponse = try await client.request(
            .createCommunity, body: body
        )
        return response.community
    }

    func deleteCommunity(id: Int) async throws -> MessageResponse {
        try await client.request(.deleteCommunity(id: id))
    }

    func join(communityId: Int) async throws -> MessageResponse {
        try await client.request(.joinCommunity(id: communityId))
    }

    func leave(communityId: Int) async throws -> MessageResponse {
        try await client.request(.leaveCommunity(id: communityId))
    }

    func fetchPosts(
        search: String? = nil,
        communityId: Int? = nil,
        perPage: Int? = nil,
        page: Int? = nil
    ) async throws -> PaginatedResponse<PostDTO> {
        try await client.request(
            .posts(search: search, communityId: communityId, perPage: perPage, page: page)
        )
    }

    func fetchPost(id: Int) async throws -> PostDTO {
        try await client.request(.post(id: id))
    }

    func deletePost(id: Int) async throws -> MessageResponse {
        try await client.request(.deletePost(id: id))
    }

    func createPost(title: String, description: String?, communityId: Int) async throws -> PostDTO {
        let body = CreatePostRequest(title: title, description: description, communityId: communityId)
        let response: CreatePostResponse = try await client.request(.createPost, body: body)
        return response.post
    }

    func toggleLike(postId: Int) async throws -> LikeResponse {
        try await client.request(.likePost(id: postId))
    }

    func addComment(postId: Int, comment: String) async throws -> CommentDTO {
        let body = CommentBody(comment: comment)
        let response: CommentResponse = try await client.request(
            .commentOnPost(id: postId), body: body
        )
        return response.comment
    }

    func replyToComment(postId: Int, commentId: Int, comment: String) async throws -> CommentDTO {
        let body = CommentBody(comment: comment)
        let response: ReplyResponse = try await client.request(
            .replyToComment(postId: postId, commentId: commentId), body: body
        )
        return response.reply
    }

    func toggleCommentLike(postId: Int, commentId: Int) async throws -> LikeResponse {
        try await client.request(.likeComment(postId: postId, commentId: commentId))
    }
}

private struct CreatePostResponse: Decodable {
    let message: String
    let post: PostDTO
}

private struct ReplyResponse: Decodable {
    let message: String
    let reply: CommentDTO
}
