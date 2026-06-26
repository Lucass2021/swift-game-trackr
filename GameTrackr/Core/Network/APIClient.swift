import Foundation

private struct LaravelErrorBody: Decodable {
    let message: String?
    let errors: [String: [String]]?
    let error: String?

    var firstMessage: String {
        if let first = errors?.values.first?.first { return first }
        if let message, !message.isEmpty { return message }
        if let error, !error.isEmpty { return error }
        return "Request failed"
    }
}

actor APIClient {
    static let shared = APIClient()

    private nonisolated let baseURL = Config.baseURL
    private let session: URLSession
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(_ endpoint: Endpoint, body: Encodable? = nil) async throws -> T {
        let token = endpoint.requiresAuth ? KeychainHelper.getToken() : nil

        guard var urlRequest = endpoint.urlRequest(baseURL: baseURL) else {
            throw APIError.networkFailure
        }

        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try encoder.encode(body)
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw APIError.networkFailure
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkFailure
        }

        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            throw mapError(statusCode: httpResponse.statusCode, data: data, response: httpResponse)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailure
        }
    }

    private func mapError(statusCode: Int, data: Data, response: HTTPURLResponse) -> APIError {
        let body = try? decoder.decode(LaravelErrorBody.self, from: data)

        switch statusCode {
        case 422:
            return .validation(body?.firstMessage ?? "Validation failed.")
        case 409:
            return .conflict(body?.firstMessage ?? "Conflict.")
        case 429:
            let retryAfter = response.value(forHTTPHeaderField: "Retry-After").flatMap(Int.init)
            return .rateLimited(retryAfter: retryAfter)
        default:
            return APIError(statusCode: statusCode)
        }
    }
}
