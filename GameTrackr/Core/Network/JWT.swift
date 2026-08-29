import Foundation

enum JWT {
    static func isExpired(_ token: String, leeway: TimeInterval = 10) -> Bool {
        guard let expiry = expiry(of: token) else { return false }
        return expiry.timeIntervalSinceNow <= leeway
    }

    private static func expiry(of token: String) -> Date? {
        let parts = token.split(separator: ".")
        guard parts.count == 3, let payload = base64Decode(String(parts[1])) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: payload) as? [String: Any],
              let exp = json["exp"] as? TimeInterval
        else { return nil }
        return Date(timeIntervalSince1970: exp)
    }

    private static func base64Decode(_ value: String) -> Data? {
        var normalized = value.replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        normalized += String(repeating: "=", count: (4 - normalized.count % 4) % 4)
        return Data(base64Encoded: normalized)
    }
}
