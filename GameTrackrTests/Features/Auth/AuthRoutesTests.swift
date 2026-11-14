import Testing
@testable import GameTrackr

@MainActor
struct AuthRoutesTests {
    @Test func aRouteNotInThePathIsPushed() {
        #expect(openAuthRoute(.register, in: [.login]) == [.login, .register])
    }

    @Test func aRouteAlreadyInThePathPopsBackToIt() {
        #expect(openAuthRoute(.login, in: [.login, .register]) == [.login])
    }

    @Test func switchingBackAndForthNeverGrowsPastLoginAndRegister() {
        var path: [AuthRoute] = []
        var longest = 0
        for route in [AuthRoute.register, .login, .register, .login, .register] {
            path = openAuthRoute(route, in: path)
            longest = max(longest, path.count)
        }
        #expect(longest == 2)
        #expect(path == [.register])
    }
}
