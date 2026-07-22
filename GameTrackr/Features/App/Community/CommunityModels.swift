import SwiftUI

enum CommunitySegment: String, CaseIterable, Identifiable {
    case myFeed = "My Feed"
    case discover = "Discover"

    var id: Self {
        self
    }
}

enum CommunityFeedFilter: String, CaseIterable, Identifiable {
    case latest = "Latest"
    case topRated = "Top Rated"
    case following = "Following"

    var id: Self {
        self
    }
}

enum CommunityDetailTab: String, CaseIterable, Identifiable {
    case posts = "Posts"
    case about = "About"
    case members = "Members"

    var id: Self {
        self
    }
}

struct Community: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: String
    let members: String
    let posts: String
    let online: String
    let description: String
    var isJoined: Bool
    let iconStart: Color
    let iconEnd: Color

    var subtitle: String {
        "#\(category) · \(members) members"
    }

    var detailSubtitle: String {
        "\(members) members · \(posts) posts · #\(category)"
    }
}

struct CommunityPost: Identifiable, Hashable {
    let id = UUID()
    let author: String
    let timeAgo: String
    let communityName: String
    let title: String
    let preview: String
    var likes: Int
    let comments: Int
    let hasMedia: Bool
    var isLiked = false
    var isBookmarked = false
    let avatarStart: Color
    let avatarEnd: Color
    let mediaStart: Color
    let mediaEnd: Color
}

struct CommunityMember: Identifiable, Hashable {
    let id = UUID()
    let author: String
    let role: String
    let avatarStart: Color
    let avatarEnd: Color
}

struct PostComment: Identifiable, Hashable {
    let id = UUID()
    let author: String
    let timeAgo: String
    let content: String
    var likes: Int
    var isLiked = false
    let avatarStart: Color
    let avatarEnd: Color
    var replies: [PostComment] = []
    var hiddenReplies = 0
}
