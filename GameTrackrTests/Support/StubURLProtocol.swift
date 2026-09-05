import Foundation

final class StubURLProtocol: URLProtocol {
    struct Stub {
        let status: Int
        let body: Data
    }

    private static let lock = NSLock()
    private nonisolated(unsafe) static var stubs: [Stub] = []
    private nonisolated(unsafe) static var paths: [String] = []
    private nonisolated(unsafe) static var authorizations: [String?] = []

    static var session: URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    static var requestedPaths: [String] {
        lock.withLock { paths }
    }

    static var sentAuthorizations: [String?] {
        lock.withLock { authorizations }
    }

    static func reset() {
        lock.withLock {
            stubs = []
            paths = []
            authorizations = []
        }
    }

    static func enqueue(status: Int = 200, json: String) {
        lock.withLock { stubs.append(Stub(status: status, body: Data(json.utf8))) }
    }

    private static func next(path: String, authorization: String?) -> Stub {
        lock.withLock {
            paths.append(path)
            authorizations.append(authorization)
            return stubs.isEmpty ? Stub(status: 500, body: Data("{}".utf8)) : stubs.removeFirst()
        }
    }

    override class func canInit(with _: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let stub = Self.next(
            path: request.url?.path ?? "",
            authorization: request.value(forHTTPHeaderField: "Authorization")
        )

        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: stub.status,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: stub.body)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
