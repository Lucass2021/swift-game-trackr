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
    case validateToken
    case me
    case forgotPassword
    case verifyResetCode
    case resetPassword

    var path: String {
        switch self {
        case .register: "/auth/register"
        case .login: "/auth/login"
        case .refresh: "/auth/refresh"
        case .logout: "/auth/logout"
        case .validateToken: "/auth/validate"
        case .me: "/profile/me"
        case .forgotPassword: "/auth/forgot-password"
        case .verifyResetCode: "/auth/verify-reset-code"
        case .resetPassword: "/auth/reset-password"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .register, .login, .refresh, .logout, .validateToken,
             .forgotPassword, .verifyResetCode, .resetPassword: .post
        case .me: .get
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .register, .login, .refresh,
             .forgotPassword, .verifyResetCode, .resetPassword: false
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
