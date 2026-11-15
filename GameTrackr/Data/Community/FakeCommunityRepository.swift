import Foundation

actor FakeCommunityRepository: CommunityRepository {
    private(set) var createCommunityCount = 0
    private(set) var fetchPostsCount = 0
    private(set) var fetchMembersCount = 0
    private(set) var likeCount = 0
    private(set) var deleteCount = 0
    private(set) var fetchCommentsCount = 0
    private(set) var sendCommentCount = 0
    private(set) var commentLikeCount = 0
    private(set) var createPostCount = 0
    private var communities: [Community]
    private var posts: [CommunityPost]
    private let members: [CommunityMember]
    private var commentStore: FakeCommentStore
    private var joinedIds: Set<Int>
    private var failure: Error?
    private let latency: Duration

    init(
        communities: [Community] = CommunityMockData.all,
        posts: [CommunityPost] = CommunityPostMockData.communityPosts,
        members: [CommunityMember] = CommunityMockData.members,
        comments: [PostComment] = CommunityPostMockData.comments,
        failure: Error? = nil,
        latency: Duration = FakeLatency.responseDelay
    ) {
        self.communities = communities
        self.posts = posts
        self.members = members
        commentStore = FakeCommentStore(comments)
        joinedIds = Set(communities.filter(\.isJoined).map(\.id))
        self.failure = failure
        self.latency = latency
    }

    func fetchCommunities(page: Int, perPage: Int, search: String?) async throws -> Page<Community> {
        try await respond()
        let query = search ?? ""
        var matches = communities.filter { query.isEmpty || $0.name.localizedCaseInsensitiveContains(query) }
        for index in matches.indices {
            matches[index].isJoined = joinedIds.contains(matches[index].id)
        }
        return fakePage(items: matches, page: page, perPage: perPage)
    }

    func fetchCommunity(id: Int) async throws -> Community {
        try await respond()
        guard var community = communities.first(where: { $0.id == id }) else { throw APIError.notFound }
        community.isJoined = joinedIds.contains(id)
        return community
    }

    func fetchJoinedCommunities() async throws -> [Community] {
        try await respond()
        return communities.filter { joinedIds.contains($0.id) }
    }

    func fetchCommunityMembers(id _: Int) async throws -> [CommunityMember] {
        fetchMembersCount += 1
        try await respond()
        return members
    }

    func createCommunity(title: String, description: String) async throws -> Community {
        createCommunityCount += 1
        try await respond()
        let id = (communities.map(\.id).max() ?? 0) + 1
        let created = Community(
            id: id,
            name: title,
            category: "General",
            memberCount: creatorMemberCount,
            postCount: 0,
            online: "1",
            description: description,
            isJoined: true,
            icon: .emerald
        )
        communities.insert(created, at: 0)
        joinedIds.insert(id)
        return created
    }

    func deleteCommunity(id: Int) async throws {
        deleteCount += 1
        try await respond()
        guard let index = communities.firstIndex(where: { $0.id == id }) else { throw APIError.notFound }
        communities.remove(at: index)
    }

    func joinCommunity(id: Int) async throws {
        try await respond()
        joinedIds.insert(id)
    }

    func leaveCommunity(id: Int) async throws {
        try await respond()
        joinedIds.remove(id)
    }

    func fetchPosts(page: Int, perPage: Int, communityId: Int?) async throws -> Page<CommunityPost> {
        fetchPostsCount += 1
        try await respond()
        let matches = posts.filter { communityId == nil || $0.communityId == nil || $0.communityId == communityId }
        return fakePage(items: matches, page: page, perPage: perPage)
    }

    func fetchPostComments(postId _: Int) async throws -> [PostComment] {
        fetchCommentsCount += 1
        try await respond()
        return commentStore.all
    }

    func createPost(title: String, description: String, communityId: Int) async throws -> CommunityPost {
        createPostCount += 1
        try await respond()
        let id = (posts.map(\.id).max() ?? 0) + 1
        let created = CommunityPost(
            id: id,
            author: "@you",
            timeAgo: "now",
            communityName: "",
            communityId: communityId,
            title: title,
            preview: description,
            likes: 0,
            comments: 0,
            hasMedia: false
        )
        posts.insert(created, at: 0)
        return created
    }

    func deletePost(id: Int) async throws {
        try await respond()
        guard let index = posts.firstIndex(where: { $0.id == id }) else { throw APIError.notFound }
        posts.remove(at: index)
    }

    func togglePostLike(id: Int) async throws -> LikeStatus {
        likeCount += 1
        try await respond()
        guard let index = posts.firstIndex(where: { $0.id == id }) else { throw APIError.notFound }
        posts[index].isLiked.toggle()
        posts[index].likes += posts[index].isLiked ? 1 : -1
        return LikeStatus(isLiked: posts[index].isLiked, likes: posts[index].likes)
    }

    func addComment(postId _: Int, comment: String) async throws -> PostComment {
        sendCommentCount += 1
        try await respond()
        return commentStore.add(comment)
    }

    func replyToComment(postId _: Int, commentId: Int, comment: String) async throws -> PostComment {
        sendCommentCount += 1
        try await respond()
        guard let created = commentStore.reply(to: commentId, comment) else { throw APIError.notFound }
        return created
    }

    func toggleCommentLike(postId _: Int, commentId: Int) async throws -> LikeStatus {
        commentLikeCount += 1
        try await respond()
        guard let status = commentStore.toggleLike(commentId) else { throw APIError.notFound }
        return status
    }

    func isJoined(_ communityId: Int) -> Bool {
        joinedIds.contains(communityId)
    }

    func post(_ id: Int) -> CommunityPost? {
        posts.first { $0.id == id }
    }

    func comment(_ id: Int) -> PostComment? {
        commentStore.find(id)
    }

    func setFailure(_ error: Error?) {
        failure = error
    }

    private func respond() async throws {
        let error = failure
        try await Task.sleep(for: latency)
        if let error { throw error }
    }
}
