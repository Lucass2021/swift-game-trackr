struct RemoteCommunityRepository: CommunityRepository {
    private let apiClient: APIClient

    nonisolated init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    func fetchCommunities(page: Int, perPage: Int, search: String?) async throws -> Page<Community> {
        let response: PaginatedResponse<CommunityDTO> = try await apiClient.request(
            .communities(search: search, perPage: perPage, page: page)
        )
        return toPage(response) { Community(dto: $0) }
    }

    func fetchCommunity(id: Int) async throws -> Community {
        let dto: CommunityDTO = try await apiClient.request(.community(id: id))
        var community = Community(dto: dto)
        community.isJoined = try await isMember(community)
        return community
    }

    private func isMember(_ community: Community) async throws -> Bool {
        do {
            let joined: PaginatedResponse<CommunityDTO> = try await apiClient.request(
                .joinedCommunities(search: community.name, perPage: Constants.joinedLookupSize)
            )
            return joined.data.contains { $0.id == community.id }
        } catch {
            try Task.checkCancellation()
            return false
        }
    }

    func fetchJoinedCommunities() async throws -> [Community] {
        let response: PaginatedResponse<CommunityDTO> = try await apiClient.request(.joinedCommunities())
        return response.data.map { Community(dto: $0) }
    }

    func fetchCommunityMembers(id: Int) async throws -> [CommunityMember] {
        let response: CommunityDTO = try await apiClient.request(.community(id: id))
        return (response.members ?? []).map { CommunityMember(dto: $0) }
    }

    func createCommunity(title: String, description: String) async throws -> Community {
        let body = CreateCommunityRequest(title: title, description: description)
        let response: CreateCommunityResponse = try await apiClient.request(.createCommunity, body: body)
        return Community(dto: response.community)
    }

    func deleteCommunity(id: Int) async throws {
        let _: MessageResponse = try await apiClient.request(.deleteCommunity(id: id))
    }

    func joinCommunity(id: Int) async throws {
        let _: MessageResponse = try await apiClient.request(.joinCommunity(id: id))
    }

    func leaveCommunity(id: Int) async throws {
        let _: MessageResponse = try await apiClient.request(.leaveCommunity(id: id))
    }

    func fetchPosts(page: Int, perPage: Int, communityId: Int?) async throws -> Page<CommunityPost> {
        let response: PaginatedResponse<PostDTO> = try await apiClient.request(
            .posts(communityId: communityId, perPage: perPage, page: page)
        )
        return toPage(response) { CommunityPost(dto: $0) }
    }

    func fetchPostComments(postId: Int) async throws -> [PostComment] {
        let response: PostDTO = try await apiClient.request(.post(id: postId))
        return toThreads(response.comments ?? [])
    }

    func createPost(title: String, description: String, communityId: Int) async throws -> CommunityPost {
        let body = CreatePostRequest(title: title, description: description, communityId: communityId)
        let response: CreatePostResponse = try await apiClient.request(.createPost, body: body)
        let created: PostDTO = try await apiClient.request(.post(id: response.post.id))
        return CommunityPost(dto: created)
    }

    func deletePost(id: Int) async throws {
        let _: MessageResponse = try await apiClient.request(.deletePost(id: id))
    }

    func togglePostLike(id: Int) async throws -> LikeStatus {
        let response: LikeResponse = try await apiClient.request(.likePost(id: id))
        return toLikeStatus(response)
    }

    func addComment(postId: Int, comment: String) async throws -> PostComment {
        let response: CommentResponse = try await apiClient.request(
            .commentOnPost(id: postId), body: CommentBody(comment: comment)
        )
        return PostComment(dto: response.comment)
    }

    func replyToComment(postId: Int, commentId: Int, comment: String) async throws -> PostComment {
        let response: ReplyResponse = try await apiClient.request(
            .replyToComment(postId: postId, commentId: commentId), body: CommentBody(comment: comment)
        )
        return PostComment(dto: response.reply)
    }

    func toggleCommentLike(postId: Int, commentId: Int) async throws -> LikeStatus {
        let response: LikeResponse = try await apiClient.request(.likeComment(postId: postId, commentId: commentId))
        return toLikeStatus(response)
    }

    private func toPage<DTO, Item>(_ response: PaginatedResponse<DTO>, transform: (DTO) -> Item) -> Page<Item> {
        Page(
            items: response.data.map(transform),
            currentPage: response.currentPage,
            lastPage: response.lastPage,
            total: response.total
        )
    }

    private func toLikeStatus(_ response: LikeResponse) -> LikeStatus {
        LikeStatus(isLiked: response.isLiked, likes: response.likes)
    }

    private func toThreads(_ comments: [CommentDTO]) -> [PostComment] {
        let byId = Dictionary(uniqueKeysWithValues: comments.map { ($0.id, $0) })

        func rootId(_ comment: CommentDTO) -> Int {
            var current = comment
            while let parentId = current.parentId, let parent = byId[parentId] {
                current = parent
            }
            return current.id
        }

        let replies = Dictionary(grouping: comments.filter { $0.parentId != nil }) { rootId($0) }
        return comments.filter { $0.parentId == nil }.map { comment in
            var thread = PostComment(dto: comment)
            thread.replies = (replies[comment.id] ?? []).map { PostComment(dto: $0) }
            return thread
        }
    }
}

private enum Constants {
    static let joinedLookupSize = 100
}
