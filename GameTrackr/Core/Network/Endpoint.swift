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
    case logout
    case validateToken
    case me

    var path: String {
        switch self {
        case .register: "/auth/register"
        case .login: "/auth/login"
        case .logout: "/auth/logout"
        case .validateToken: "/auth/validate"
        case .me: "/profile/me"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .register, .login, .logout, .validateToken: .post
        case .me: .get
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .register, .login: false
        case .logout, .validateToken, .me: true
        }
    }

    func urlRequest(baseURL: String) -> URLRequest? {
        guard let url = URL(string: baseURL + path) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        return request
    }
}
