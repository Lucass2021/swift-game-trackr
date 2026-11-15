import Foundation

nonisolated struct Community: Identifiable, Hashable {
    let id: Int
    let name: String
    let authorId: Int?
    let category: String
    var memberCount: Int
    let postCount: Int
    let description: String
    var isJoined: Bool
    let avatarUrl: String?
    let coverUrl: String?
    let icon: CoverPalette
    let createdMonth: String?

    let online: String

    var members: String {
        memberCount.abbreviated
    }

    var posts: String {
        postCount.abbreviated
    }

    var subtitle: String {
        "#\(category) · \(members) members"
    }

    var detailSubtitle: String {
        "\(members) members · \(posts) posts · #\(category)"
    }

    init(
        id: Int,
        name: String,
        authorId: Int? = nil,
        category: String = "General",
        memberCount: Int = 0,
        postCount: Int = 0,
        online: String = "--",
        description: String = "",
        isJoined: Bool = false,
        avatarUrl: String? = nil,
        coverUrl: String? = nil,
        icon: CoverPalette? = nil,
        createdMonth: String? = nil
    ) {
        self.id = id
        self.name = name
        self.authorId = authorId
        self.category = category
        self.memberCount = memberCount
        self.postCount = postCount
        self.online = online
        self.description = description
        self.isJoined = isJoined
        self.avatarUrl = avatarUrl
        self.coverUrl = coverUrl
        self.icon = icon ?? CoverPalette.forGradientId(id)
        self.createdMonth = createdMonth
    }
}

nonisolated struct CommunityPost: Identifiable, Hashable {
    private static let mediaPaletteOffset = 3

    let id: Int
    let author: String
    let authorId: Int?
    let authorUsername: String?
    let timeAgo: String
    let communityName: String
    let communityId: Int?
    let title: String
    let preview: String
    var likes: Int
    let comments: Int
    let hasMedia: Bool
    var isLiked = false
    var isBookmarked = false
    let imageUrl: String?
    let avatarUrl: String?
    let avatar: CoverPalette
    let media: CoverPalette

    init(
        id: Int,
        author: String,
        authorId: Int? = nil,
        authorUsername: String? = nil,
        timeAgo: String,
        communityName: String,
        communityId: Int? = nil,
        title: String,
        preview: String,
        likes: Int,
        comments: Int,
        hasMedia: Bool,
        isLiked: Bool = false,
        isBookmarked: Bool = false,
        imageUrl: String? = nil,
        avatarUrl: String? = nil,
        avatar: CoverPalette? = nil,
        media: CoverPalette? = nil
    ) {
        self.id = id
        self.author = author
        self.authorId = authorId
        self.authorUsername = authorUsername
        self.timeAgo = timeAgo
        self.communityName = communityName
        self.communityId = communityId
        self.title = title
        self.preview = preview
        self.likes = likes
        self.comments = comments
        self.hasMedia = hasMedia
        self.isLiked = isLiked
        self.isBookmarked = isBookmarked
        self.imageUrl = imageUrl
        self.avatarUrl = avatarUrl
        self.avatar = avatar ?? CoverPalette.forGradientId(id)
        self.media = media ?? CoverPalette.forGradientId(id + Self.mediaPaletteOffset)
    }
}

nonisolated struct CommunityMember: Identifiable, Hashable {
    let id: Int
    let author: String
    let role: String
    let avatarUrl: String?
    let avatar: CoverPalette
    let username: String?

    init(
        id: Int,
        author: String,
        role: String,
        avatarUrl: String? = nil,
        avatar: CoverPalette? = nil,
        username: String? = nil
    ) {
        self.id = id
        self.author = author
        self.role = role
        self.avatarUrl = avatarUrl
        self.username = username
        self.avatar = avatar ?? CoverPalette.forGradientId(id)
    }
}

nonisolated struct PostComment: Identifiable, Hashable {
    let id: Int
    let author: String
    let authorId: Int?
    let timeAgo: String
    let content: String
    var likes: Int
    var isLiked = false
    let avatarUrl: String?
    let avatar: CoverPalette
    var replies: [PostComment] = []

    init(
        id: Int,
        author: String,
        authorId: Int? = nil,
        timeAgo: String,
        content: String,
        likes: Int,
        isLiked: Bool = false,
        avatarUrl: String? = nil,
        avatar: CoverPalette? = nil,
        replies: [PostComment] = []
    ) {
        self.id = id
        self.author = author
        self.authorId = authorId
        self.timeAgo = timeAgo
        self.content = content
        self.likes = likes
        self.isLiked = isLiked
        self.avatarUrl = avatarUrl
        self.avatar = avatar ?? CoverPalette.forGradientId(id)
        self.replies = replies
    }
}

nonisolated extension PostComment: Sendable {}

nonisolated struct LikeStatus: Hashable {
    let isLiked: Bool
    let likes: Int
}
