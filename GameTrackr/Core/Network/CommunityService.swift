import Foundation

struct CommunityService {
    static let shared = CommunityService()

    func fetchCommunities(search: String? = nil, perPage: Int? = nil, page: Int? = nil) async throws
        -> PaginatedResponse<CommunityDTO>
    {
        try await APIClient.shared.request(.communities(search: search, perPage: perPage, page: page))
    }

    func fetchJoinedCommunities() async throws -> PaginatedResponse<CommunityDTO> {
        try await APIClient.shared.request(.joinedCommunities)
    }

    func fetchCommunity(id: Int) async throws -> CommunityDTO {
        try await APIClient.shared.request(.community(id: id))
    }

    func join(communityId: Int) async throws -> MessageResponse {
        try await APIClient.shared.request(.joinCommunity(id: communityId))
    }

    func leave(communityId: Int) async throws -> MessageResponse {
        try await APIClient.shared.request(.leaveCommunity(id: communityId))
    }

    func fetchPosts(
        search: String? = nil,
        communityId: Int? = nil,
        perPage: Int? = nil,
        page: Int? = nil
    ) async throws -> PaginatedResponse<PostDTO> {
        try await APIClient.shared.request(
            .posts(search: search, communityId: communityId, perPage: perPage, page: page)
        )
    }

    func fetchPost(id: Int) async throws -> PostDTO {
        try await APIClient.shared.request(.post(id: id))
    }

    func deletePost(id: Int) async throws -> MessageResponse {
        try await APIClient.shared.request(.deletePost(id: id))
    }

    func createPost(title: String, description: String?, communityId: Int) async throws -> PostDTO {
        let body = CreatePostRequest(title: title, description: description, communityId: communityId)
        let response: CreatePostResponse = try await APIClient.shared.request(.createPost, body: body)
        return response.post
    }

    func toggleLike(postId: Int) async throws -> LikeResponse {
        try await APIClient.shared.request(.likePost(id: postId))
    }

    func addComment(postId: Int, comment: String) async throws -> CommentDTO {
        let body = CommentBody(comment: comment)
        let response: CommentResponse = try await APIClient.shared.request(
            .commentOnPost(id: postId), body: body
        )
        return response.comment
    }

    func replyToComment(postId: Int, commentId: Int, comment: String) async throws -> CommentDTO {
        let body = CommentBody(comment: comment)
        let response: ReplyResponse = try await APIClient.shared.request(
            .replyToComment(postId: postId, commentId: commentId), body: body
        )
        return response.reply
    }

    func toggleCommentLike(postId: Int, commentId: Int) async throws -> LikeResponse {
        try await APIClient.shared.request(.likeComment(postId: postId, commentId: commentId))
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
