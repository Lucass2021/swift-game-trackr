import Foundation
import Testing
@testable import GameTrackr

@MainActor
struct GameDetailMappingTests {
    private static let coverURL = "https://images.example.com/cover.jpg"
    private static let screenshotURL = "https://images.example.com/shot.jpg"
    private static let fullBody = #"""
    {"id":7,"name":"Neon Ascent","summary":"A cyberpunk climb.","first_release_date":1710417600,\#
    "total_rating":87.0,"rating":50.0,"cover":{"url":"\#(coverURL)"},\#
    "screenshots":[{"url":"\#(screenshotURL)"},{"url":"\#(coverURL)"}],\#
    "platforms":[{"name":"PlayStation 5","slug":"ps5","abbreviation":"PS5"}],\#
    "genres":[{"name":"Action RPG"}],"themes":[{"name":"Cyberpunk"}],\#
    "game_modes":[{"name":"Single player"},{"name":"Co-operative"}],\#
    "involved_companies":[{"company":{"name":"Void Interactive"},"developer":true,"publisher":false},\#
    {"company":{"name":"Nova Games"},"developer":false,"publisher":true}],\#
    "release_dates":[{"human":"Mar 14, 2024"}]}
    """#
    private static let storylineBody = #"""
    {"id":7,"name":"Neon Ascent","storyline":"A long story.","cover":{"url":"\#(coverURL)"}}
    """#
    private static let minimalBody = #"{"id":7,"name":"Neon Ascent"}"#

    @Test func mapsTheHeaderArtworkScreenshotsAndSpecs() throws {
        let game = try decode(Self.fullBody)

        #expect(game.title == "Neon Ascent")
        #expect(game.year == "2024")
        #expect(game.rating == 8.7)
        #expect(game.platforms == ["PS5"])
        #expect(game.genres == ["Action RPG", "Cyberpunk"])
        #expect(game.heroURL == Self.screenshotURL)
        #expect(game.screenshots.map(\.url) == [Self.screenshotURL, Self.coverURL])
        #expect(game.about == "A cyberpunk climb.")
        #expect(game.specs.map(\.label) == ["Developer", "Publisher", "Released", "Modes"])
        #expect(game.specs.map(\.value) == [
            "Void Interactive",
            "Nova Games",
            "Mar 14, 2024",
            "Single player, Co-operative"
        ])
    }

    @Test func missingFieldsFallBackToTBATheCoverTheStorylineAndNoSpecs() throws {
        let game = try decode(Self.storylineBody)

        #expect(game.year == "TBA")
        #expect(game.rating == nil)
        #expect(game.heroURL == Self.coverURL)
        #expect(game.screenshots.isEmpty)
        #expect(game.about == "A long story.")
        #expect(game.specs.isEmpty)
    }

    @Test func aGameWithoutAnyDescriptionShowsTheDefaultText() throws {
        let game = try decode(Self.minimalBody)

        #expect(game.about == "No description available yet.")
        #expect(game.heroURL == nil)
    }

    private func decode(_ json: String) throws -> GameDetail {
        try GameDetail(dto: JSONDecoder().decode(GameDetailDTO.self, from: Data(json.utf8)))
    }
}
