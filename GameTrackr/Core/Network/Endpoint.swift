import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum Endpoint {
    case register
    case login
    case refresh
    case logout
    case me
    case updateProfile
    case profileColors
    case forgotPassword
    case verifyResetCode
    case resetPassword

    case newReleases(limit: Int? = nil)
    case allNewReleases(page: Int? = nil, perPage: Int? = nil, search: String? = nil, platforms: [String] = [])
    case mostAnticipated(limit: Int? = nil)
    case allMostAnticipated(page: Int? = nil, perPage: Int? = nil, search: String? = nil, platforms: [String] = [])
    case game(slug: String)
    case platforms

    case communities(search: String? = nil, perPage: Int? = nil, page: Int? = nil)
    case joinedCommunities
    case community(id: Int)
    case createCommunity
    case deleteCommunity(id: Int)
    case joinCommunity(id: Int)
    case leaveCommunity(id: Int)

    case posts(search: String? = nil, communityId: Int? = nil, perPage: Int? = nil, page: Int? = nil)
    case post(id: Int)
    case createPost
    case deletePost(id: Int)
    case likePost(id: Int)
    case commentOnPost(id: Int)
    case replyToComment(postId: Int, commentId: Int)
    case likeComment(postId: Int, commentId: Int)

    var path: String {
        switch self {
        case .register: "/auth/register"
        case .login: "/auth/login"
        case .refresh: "/auth/refresh"
        case .logout: "/auth/logout"
        case .me: "/profile/me"
        case .updateProfile: "/profile"
        case .profileColors: "/profile/colors"
        case .forgotPassword: "/auth/forgot-password"
        case .verifyResetCode: "/auth/verify-reset-code"
        case .resetPassword: "/auth/reset-password"
        case .newReleases: "/home/new-releases"
        case .allNewReleases: "/home/new-releases/all"
        case .mostAnticipated: "/home/most-anticipated"
        case .allMostAnticipated: "/home/most-anticipated/all"
        case let .game(slug): "/games/\(slug)"
        case .platforms: "/platforms"
        case .communities: "/communities"
        case .joinedCommunities: "/communities/joined"
        case let .community(id): "/communities/\(id)"
        case .createCommunity: "/communities"
        case let .deleteCommunity(id): "/communities/\(id)"
        case let .joinCommunity(id): "/communities/join/\(id)"
        case let .leaveCommunity(id): "/communities/leave/\(id)"
        case .posts: "/posts"
        case let .post(id): "/posts/\(id)"
        case .createPost: "/posts"
        case let .deletePost(id): "/posts/\(id)"
        case let .likePost(id): "/posts/\(id)/like"
        case let .commentOnPost(id): "/posts/\(id)/comment"
        case let .replyToComment(postId, commentId):
            "/posts/\(postId)/comment/\(commentId)/reply"
        case let .likeComment(postId, commentId):
            "/posts/\(postId)/comment/\(commentId)/like"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .register, .login, .refresh, .logout,
             .forgotPassword, .verifyResetCode, .resetPassword,
             .joinCommunity, .leaveCommunity, .createCommunity,
             .createPost, .likePost, .commentOnPost, .replyToComment, .likeComment:
            .post
        case .me, .profileColors, .communities, .joinedCommunities, .community, .posts, .post,
             .newReleases, .allNewReleases,
             .mostAnticipated, .allMostAnticipated, .game, .platforms:
            .get
        case .deletePost, .deleteCommunity:
            .delete
        case .updateProfile:
            .patch
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .register, .login, .refresh,
             .forgotPassword, .verifyResetCode, .resetPassword,
             .newReleases, .allNewReleases,
             .mostAnticipated, .allMostAnticipated, .game, .platforms:
            false
        default:
            true
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case let .newReleases(limit), let .mostAnticipated(limit):
            guard let limit else { return nil }
            return [.init(name: "limit", value: "\(limit)")]
        case let .allNewReleases(page, perPage, search, platforms),
             let .allMostAnticipated(page, perPage, search, platforms):
            var items: [URLQueryItem] = []
            if let page { items.append(.init(name: "page", value: "\(page)")) }
            if let perPage { items.append(.init(name: "per_page", value: "\(perPage)")) }
            if let search, !search.isEmpty { items.append(.init(name: "search", value: search)) }
            items.append(contentsOf: platforms.map { URLQueryItem(name: "platform[]", value: $0) })
            return items.isEmpty ? nil : items
        case let .communities(search, perPage, page):
            var items: [URLQueryItem] = []
            if let search, !search.isEmpty { items.append(.init(name: "search", value: search)) }
            if let perPage { items.append(.init(name: "per_page", value: "\(perPage)")) }
            if let page { items.append(.init(name: "page", value: "\(page)")) }
            return items.isEmpty ? nil : items
        case let .posts(search, communityId, perPage, page):
            var items: [URLQueryItem] = []
            if let search, !search.isEmpty { items.append(.init(name: "search", value: search)) }
            if let communityId { items.append(.init(name: "community_id", value: "\(communityId)")) }
            if let perPage { items.append(.init(name: "per_page", value: "\(perPage)")) }
            if let page { items.append(.init(name: "page", value: "\(page)")) }
            return items.isEmpty ? nil : items
        default:
            return nil
        }
    }

    func urlRequest(baseURL: String) -> URLRequest? {
        guard var components = URLComponents(string: baseURL + path) else { return nil }
        if let items = queryItems, !items.isEmpty {
            components.queryItems = items
        }
        guard let url = components.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        return request
    }
}
