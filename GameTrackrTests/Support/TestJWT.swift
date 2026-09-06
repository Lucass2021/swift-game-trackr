import Foundation

enum TestJWT {
    static func token(payload: String) -> String {
        "\(base64url("{\"alg\":\"HS256\",\"typ\":\"JWT\"}")).\(base64url(payload)).signature"
    }

    static func token(expiringIn seconds: TimeInterval) -> String {
        token(payload: "{\"exp\":\(Int(Date().timeIntervalSince1970 + seconds))}")
    }

    static func base64url(_ value: String) -> String {
        Data(value.utf8).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
