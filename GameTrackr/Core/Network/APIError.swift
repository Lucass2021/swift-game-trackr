import Foundation

enum APIError: LocalizedError {
    case unauthorized
    case notFound
    case conflict(String)
    case validation(String)
    case rateLimited(retryAfter: Int?)
    case serverError
    case networkFailure
    case decodingFailure
    case unknown(statusCode: Int)

    init(statusCode: Int, retryAfter: Int? = nil) {
        switch statusCode {
        case 401: self = .unauthorized
        case 404: self = .notFound
        case 429: self = .rateLimited(retryAfter: retryAfter)
        case 500...: self = .serverError
        default: self = .unknown(statusCode: statusCode)
        }
    }

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Invalid email or password."
        case .notFound:
            return "Account not found."
        case let .conflict(message):
            return message
        case let .validation(message):
            return message
        case let .rateLimited(retryAfter):
            if let seconds = retryAfter {
                return "Too many attempts. Try again in \(seconds)s."
            }
            return "Too many attempts. Please wait a moment."
        case .serverError:
            return "Server error. Please try again later."
        case .networkFailure:
            return "No internet connection. Check your network and try again."
        case .decodingFailure:
            return "Unexpected response from the server."
        case let .unknown(code):
            return "Unexpected error (code \(code))."
        }
    }
}
