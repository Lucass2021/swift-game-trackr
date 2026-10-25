import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct ProfileModelsTests {
    @Test func profileFromAUserMapsEveryField() {
        let joinedAt = Date(timeIntervalSince1970: 1_767_312_000)
        let user = User(
            id: 1,
            name: "Ada",
            email: "ada@example.com",
            username: "ada",
            profileColor: "#10B981",
            bio: "Speedruns",
            visibility: .privateProfile,
            createdAt: joinedAt
        )

        let profile = Profile(user: user)

        #expect(profile.name == "Ada")
        #expect(profile.username == "@ada")
        #expect(profile.bio == "Speedruns")
        #expect(profile.joinedAt == joinedAt)
        #expect(profile.avatarHex == "#10B981")
        #expect(profile.visibility == .privateProfile)
    }

    @Test func profileFromAUserWithoutOptionalFieldsShowsNoMockData() {
        let user = User(id: 1, name: "Ada", email: "ada@example.com")

        let profile = Profile(user: user)

        #expect(profile.name == "Ada")
        #expect(profile.username.isEmpty)
        #expect(profile.bio.isEmpty)
        #expect(profile.joinedAt == nil)
        #expect(profile.avatarHex == Profile.defaultAvatarHex)
        #expect(profile.visibility == .publicProfile)
    }
}
