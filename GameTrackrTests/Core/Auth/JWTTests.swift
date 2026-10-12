import Foundation
import Testing
@testable import GameTrackr

struct JWTTests {
    private static let now = Date(timeIntervalSince1970: 1_800_000_000)
    private static let oneHour: TimeInterval = 3600
    private static let insideLeeway: TimeInterval = 5

    @Test func tokenWithExpInTheFutureIsNotExpired() {
        let token = Self.token(payload: #"{"exp":\#(Int(Self.now.timeIntervalSince1970 + Self.oneHour))}"#)
        #expect(!JWT.isExpired(token, now: Self.now))
    }

    @Test func tokenWithExpInThePastIsExpired() {
        let token = Self.token(payload: #"{"exp":\#(Int(Self.now.timeIntervalSince1970 - Self.oneHour))}"#)
        #expect(JWT.isExpired(token, now: Self.now))
    }

    @Test func tokenExpiringInsideTheLeewayIsExpired() {
        let token = Self.token(payload: #"{"exp":\#(Int(Self.now.timeIntervalSince1970 + Self.insideLeeway))}"#)
        #expect(JWT.isExpired(token, now: Self.now))
    }

    @Test func tokenWithoutExpIsNotExpired() {
        #expect(!JWT.isExpired(Self.token(payload: #"{"sub":"1"}"#), now: Self.now))
    }

    @Test func malformedTokenIsNotExpired() {
        #expect(!JWT.isExpired("not-a-jwt", now: Self.now))
    }

    private static func token(payload: String) -> String {
        let encoded = Data(payload.utf8).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        return "header.\(encoded).signature"
    }
}
