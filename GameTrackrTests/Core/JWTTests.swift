import Foundation
import Testing
@testable import GameTrackr

struct JWTTests {
    @Test func treatsAnAlreadyExpiredTokenAsExpired() {
        #expect(JWT.isExpired(TestJWT.token(expiringIn: -60)))
    }

    @Test func treatsATokenWithPlentyOfLifeLeftAsValid() {
        #expect(!JWT.isExpired(TestJWT.token(expiringIn: 3600)))
    }

    @Test func expiresATokenThatDiesInsideTheLeeway() {
        #expect(JWT.isExpired(TestJWT.token(expiringIn: 5)))
        #expect(!JWT.isExpired(TestJWT.token(expiringIn: 5), leeway: 0))
    }

    @Test func decodesABase64URLPayloadWithoutPadding() {
        let payload = "{\"exp\":2000000000,\"sub\":\"?>?\",\"jti\":\"a?b\"}"
        let token = TestJWT.token(payload: payload)

        #expect(token.split(separator: ".")[1].contains("-"))
        #expect(token.split(separator: ".")[1].contains("_"))
        #expect(!JWT.isExpired(token))
    }

    @Test func repadsAPayloadWhoseLengthIsNotAMultipleOfFour() {
        let token = TestJWT.token(payload: "{\"exp\":2000000000,\"a\":12}")

        #expect(token.split(separator: ".")[1].count % 4 != 0)
        #expect(!JWT.isExpired(token))
    }

    @Test func doesNotExpireATokenItCannotRead() {
        #expect(!JWT.isExpired(""))
        #expect(!JWT.isExpired("not-a-jwt"))
        #expect(!JWT.isExpired("only.two"))
        #expect(!JWT.isExpired("a.!!!not-base64!!!.c"))
        #expect(!JWT.isExpired(TestJWT.token(payload: "not json")))
        #expect(!JWT.isExpired(TestJWT.token(payload: "{\"sub\":\"lucas\"}")))
    }
}
