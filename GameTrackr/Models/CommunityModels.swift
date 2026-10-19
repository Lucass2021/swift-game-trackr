import SwiftUI

struct Community: Identifiable, Hashable {
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
    let iconStart: Color
    let iconEnd: Color
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
        iconStart: Color? = nil,
        iconEnd: Color? = nil,
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
        let colors = GradientPalette.pair(for: id)
        self.iconStart = iconStart ?? colors.0
        self.iconEnd = iconEnd ?? colors.1
        self.createdMonth = createdMonth
    }

    init(dto: CommunityDTO) {
        let avatar = dto.media?.first(where: { $0.collectionName == "avatar" })?.originalUrl
        let cover = dto.media?.first(where: { $0.collectionName == "cover" })?.originalUrl
        self.init(
            id: dto.id,
            name: dto.title,
            authorId: dto.authorId,
            memberCount: dto.members?.count ?? 0,
            description: dto.description ?? "",
            isJoined: dto.isMember ?? false,
            avatarUrl: avatar,
            coverUrl: cover,
            createdMonth: Self.monthYear(from: dto.createdAt)
        )
    }

    private static let monthYearFormat = Date.FormatStyle(locale: Locale(identifier: "en_US"), timeZone: .gmt)
        .month(.wide)
        .year()

    private static func monthYear(from iso: String?) -> String? {
        guard let iso else { return nil }
        let day = String(iso.prefix(10))
        guard let date = try? Date(day, strategy: Date.ISO8601FormatStyle(timeZone: .gmt).year().month().day()) else {
            return nil
        }
        return date.formatted(monthYearFormat)
    }
}

struct CommunityPost: Identifiable, Hashable {
    let id: Int
    let author: String
    let authorId: Int?
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
    let avatarStart: Color
    let avatarEnd: Color
    let mediaStart: Color
    let mediaEnd: Color

    init(
        id: Int,
        author: String,
        authorId: Int? = nil,
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
        avatarStart: Color? = nil,
        avatarEnd: Color? = nil,
        mediaStart: Color? = nil,
        mediaEnd: Color? = nil
    ) {
        self.id = id
        self.author = author
        self.authorId = authorId
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
        let aColors = GradientPalette.pair(for: id)
        self.avatarStart = avatarStart ?? aColors.0
        self.avatarEnd = avatarEnd ?? aColors.1
        let mColors = GradientPalette.pair(for: id + 3)
        self.mediaStart = mediaStart ?? mColors.0
        self.mediaEnd = mediaEnd ?? mColors.1
    }

    init(dto: PostDTO) {
        let firstImage = dto.media?.first?.originalUrl
        self.init(
            id: dto.id,
            author: "@\(dto.author?.name ?? "Unknown")",
            authorId: dto.authorId,
            timeAgo: Self.formatDate(dto.createdAt),
            communityName: dto.community?.title ?? "",
            communityId: dto.communityId,
            title: dto.title,
            preview: dto.description ?? "",
            likes: dto.likes ?? 0,
            comments: dto.comments?.count ?? 0,
            hasMedia: firstImage != nil,
            isLiked: dto.isLiked ?? false,
            imageUrl: firstImage,
            avatarUrl: dto.author?.avatarUrl
        )
    }

    private static func formatDate(_ iso: String?) -> String {
        guard let iso, let date = ISO8601DateFormatter().date(from: iso) else { return "" }
        let interval = Date().timeIntervalSince(date)
        switch interval {
        case ..<60: return "now"
        case ..<3600: return "\(Int(interval / 60))m ago"
        case ..<86400: return "\(Int(interval / 3600))h ago"
        case ..<604_800: return "\(Int(interval / 86400))d ago"
        default: return date.formatted(.dateTime.month().day())
        }
    }
}

struct CommunityMember: Identifiable, Hashable {
    let id: Int
    let author: String
    let role: String
    let avatarUrl: String?
    let avatarStart: Color
    let avatarEnd: Color

    init(
        id: Int,
        author: String,
        role: String,
        avatarUrl: String? = nil,
        avatarStart: Color? = nil,
        avatarEnd: Color? = nil
    ) {
        self.id = id
        self.author = author
        self.role = role
        self.avatarUrl = avatarUrl
        let colors = GradientPalette.pair(for: id)
        self.avatarStart = avatarStart ?? colors.0
        self.avatarEnd = avatarEnd ?? colors.1
    }

    init(dto: CommunityUserDTO) {
        self.init(
            id: dto.id,
            author: "@\(dto.name)",
            role: "Member",
            avatarUrl: dto.avatarUrl
        )
    }
}

struct PostComment: Identifiable, Hashable {
    let id: Int
    let author: String
    let authorId: Int?
    let timeAgo: String
    let content: String
    var likes: Int
    var isLiked = false
    let avatarUrl: String?
    let avatarStart: Color
    let avatarEnd: Color
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
        avatarStart: Color? = nil,
        avatarEnd: Color? = nil,
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
        let colors = GradientPalette.pair(for: id)
        self.avatarStart = avatarStart ?? colors.0
        self.avatarEnd = avatarEnd ?? colors.1
        self.replies = replies
    }

    init(dto: CommentDTO) {
        self.init(
            id: dto.id,
            author: "@\(dto.author?.name ?? "Unknown")",
            authorId: dto.authorId,
            timeAgo: Self.formatDate(dto.createdAt),
            content: dto.content,
            likes: dto.likes ?? 0,
            isLiked: dto.isLiked ?? false,
            avatarUrl: dto.author?.avatarUrl
        )
    }

    private static func formatDate(_ iso: String?) -> String {
        guard let iso, let date = ISO8601DateFormatter().date(from: iso) else { return "" }
        let interval = Date().timeIntervalSince(date)
        switch interval {
        case ..<60: return "now"
        case ..<3600: return "\(Int(interval / 60))m"
        case ..<86400: return "\(Int(interval / 3600))h"
        default: return "\(Int(interval / 86400))d"
        }
    }
}

extension [PostComment] {
    var totalCount: Int {
        reduce(0) { $0 + 1 + $1.replies.count }
    }
}

struct LikeStatus: Hashable {
    let isLiked: Bool
    let likes: Int
}

enum GradientPalette {
    private static let pairs: [(Color, Color)] = [
        (.coverEmeraldStart, .coverEmeraldEnd),
        (.coverCrimsonStart, .coverCrimsonEnd),
        (.coverIndigoStart, .coverIndigoEnd),
        (.coverAzureStart, .coverAzureEnd),
        (.coverVioletStart, .coverVioletEnd),
        (.coverCyanStart, .coverCyanEnd),
        (.coverPineStart, .coverPineEnd)
    ]

    static func pair(for id: Int) -> (Color, Color) {
        pairs[abs(id) % pairs.count]
    }
}
