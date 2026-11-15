import Foundation

nonisolated extension Community {
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

nonisolated extension CommunityPost {
    init(dto: PostDTO) {
        let firstImage = dto.media?.first?.originalUrl
        self.init(
            id: dto.id,
            author: "@\(dto.author?.name ?? "Unknown")",
            authorId: dto.authorId,
            authorUsername: dto.author?.username,
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

nonisolated extension CommunityMember {
    init(dto: CommunityUserDTO) {
        self.init(
            id: dto.id,
            author: "@\(dto.name)",
            role: "Member",
            avatarUrl: dto.avatarUrl,
            username: dto.username
        )
    }
}

nonisolated extension PostComment {
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
