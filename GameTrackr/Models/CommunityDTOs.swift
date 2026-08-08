import Foundation

struct CommunityDTO: Decodable {
    let id: Int
    let title: String
    let slug: String
    let description: String?
    let authorId: Int
    let author: CommunityUserDTO?
    let members: [CommunityUserDTO]?
    let media: [MediaDTO]?
    let isMember: Bool?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, slug, description, author, members, media
        case authorId = "author_id"
        case isMember = "is_member"
        case createdAt = "created_at"
    }
}

struct PostDTO: Decodable {
    let id: Int
    let title: String
    let slug: String
    let description: String?
    let communityId: Int
    let authorId: Int
    let likes: Int?
    let isLiked: Bool?
    let author: CommunityUserDTO?
    let community: CommunityDTO?
    let media: [MediaDTO]?
    let comments: [CommentDTO]?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, slug, description, likes, author, community, media, comments
        case communityId = "community_id"
        case authorId = "author_id"
        case isLiked = "is_liked"
        case createdAt = "created_at"
    }
}

struct CommentDTO: Decodable {
    let id: Int
    let content: String
    let authorId: Int
    let postId: Int
    let parentId: Int?
    let likes: Int?
    let isLiked: Bool?
    let author: CommunityUserDTO?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, content, likes, author
        case authorId = "author_id"
        case postId = "post_id"
        case parentId = "parent_id"
        case isLiked = "is_liked"
        case createdAt = "created_at"
    }
}

struct CommunityUserDTO: Decodable {
    let id: Int
    let name: String
    let email: String?
    let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case avatarUrl = "avatar_url"
    }
}

struct MediaDTO: Decodable {
    let id: Int?
    let originalUrl: String
    let collectionName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case originalUrl = "original_url"
        case collectionName = "collection_name"
    }
}

struct LikeResponse: Decodable {
    let message: String
    let isLiked: Bool
    let likes: Int

    enum CodingKeys: String, CodingKey {
        case message
        case isLiked = "is_liked"
        case likes
    }
}

struct CommentResponse: Decodable {
    let message: String
    let comment: CommentDTO
}

struct CreateCommunityResponse: Decodable {
    let community: CommunityDTO
    let message: String
}

struct CreatePostRequest: Encodable {
    let title: String
    let description: String?
    let communityId: Int

    enum CodingKeys: String, CodingKey {
        case title, description
        case communityId = "community_id"
    }
}

struct CommentBody: Encodable {
    let comment: String
}
