import Foundation
import Testing
@testable import GameTrackr

struct GameMappingTests {
    private let decoder = JSONDecoder()
    private let midYear2022 = 1_655_294_400

    private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
        try decoder.decode(type, from: Data(json.utf8))
    }

    @Test func decodesAGameWithEveryOptionalKeyOmitted() throws {
        let dto = try decode(GameDTO.self, #"{"id":1,"name":"Elden Ring"}"#)
        let game = Game(dto: dto)

        #expect(game.slug == "")
        #expect(game.coverUrl == nil)
        #expect(game.releaseDate == nil)
        #expect(game.rating == nil)
        #expect(game.year == "TBA")
        #expect(game.platformsLabel == "Platform TBA")
    }

    @Test func readsFirstReleaseDateAsAUnixTimestampNotISO8601() throws {
        let dto = try decode(GameDTO.self, #"{"id":1,"name":"Hades II","first_release_date":\#(midYear2022)}"#)
        let game = Game(dto: dto)

        #expect(game.releaseDate == Date(timeIntervalSince1970: TimeInterval(midYear2022)))
        #expect(game.year == "2022")
    }

    @Test func prefersTotalRatingOverRating() throws {
        let both = try decode(GameDTO.self, #"{"id":1,"name":"A","total_rating":91.5,"rating":70.0}"#)
        let only = try decode(GameDTO.self, #"{"id":1,"name":"A","rating":70.0}"#)

        #expect(Game(dto: both).rating == 91.5)
        #expect(Game(dto: only).rating == 70.0)
    }

    @Test func shortensTheRealIGDBPlatformSlugs() {
        #expect(PlatformLabel.short(slug: "ps4--1", name: "PlayStation 4") == "PS4")
        #expect(PlatformLabel.short(slug: "switch-2", name: "Nintendo Switch 2") == "Switch 2")
        #expect(PlatformLabel.short(slug: "series-x-s", name: "Xbox Series X|S") == "Xbox Series")
        #expect(PlatformLabel.short(slug: "win", name: "PC (Microsoft Windows)") == "PC")
    }

    @Test func fallsBackToTheNameBeforeTheParenthesisForAnUnknownSlug() {
        #expect(PlatformLabel.short(slug: "amiga", name: "Amiga (500)") == "Amiga")
        #expect(PlatformLabel.short(slug: nil, name: nil) == nil)
    }

    @Test func dedupesPlatformLabelsThatCollapseToTheSameName() throws {
        let json = """
        {"id":1,"name":"Halo","platforms":[
          {"id":1,"name":"Xbox Series X|S","slug":"series-x-s"},
          {"id":2,"name":"Xbox Series X","slug":"series-x"},
          {"id":3,"name":"PC (Microsoft Windows)","slug":"win"}
        ]}
        """
        let game = try Game(dto: decode(GameDTO.self, json))

        #expect(game.platformNames == ["Xbox Series", "PC"])
    }

    @Test func summarisesMoreThanThreePlatformsWithACounter() {
        let game = Game(id: 1, name: "A", platformNames: ["PS5", "PS4", "Switch", "PC", "Xbox One"])

        #expect(game.platformsLabel == "PS5, PS4, Switch +2")
    }

    @Test func decodesTheFlatLaravelPaginationShape() throws {
        let json = #"{"data":[7,8],"current_page":2,"last_page":5,"per_page":20,"total":100}"#
        let page = try decode(PaginatedResponse<Int>.self, json)

        #expect(page.data == [7, 8])
        #expect(page.currentPage == 2)
        #expect(page.lastPage == 5)
        #expect(page.total == 100)
    }

    @Test func mapsTheNestedIGDBMetaOntoTheSamePaginatedModel() throws {
        let json = """
        {"message":"ok","data":[{"id":1,"name":"Elden Ring"}],
         "meta":{"page":2,"per_page":20,"total":100,"last_page":5,"has_more":true}}
        """
        let page = try decode(PaginatedGamesResponse.self, json).page

        #expect(page.currentPage == 2)
        #expect(page.lastPage == 5)
        #expect(page.perPage == 20)
        #expect(page.total == 100)
        #expect(page.data.map(\.name) == ["Elden Ring"])
    }
}

struct GameDetailMappingTests {
    private func decode(_ json: String) throws -> GameDetailDTO {
        try JSONDecoder().decode(GameDetailDTO.self, from: Data(json.utf8))
    }

    @Test func prefersAScreenshotOverArtworkAndCoverForTheHero() throws {
        let all = try decode("""
        {"id":1,"name":"A","cover":{"url":"cover"},
         "artworks":[{"url":"art"}],"screenshots":[{"url":"shot"}]}
        """)
        let noShots = try decode(#"{"id":1,"name":"A","cover":{"url":"cover"},"artworks":[{"url":"art"}]}"#)
        let coverOnly = try decode(#"{"id":1,"name":"A","cover":{"url":"cover"}}"#)

        #expect(GameDetail(dto: all).heroURL == "shot")
        #expect(GameDetail(dto: noShots).heroURL == "art")
        #expect(GameDetail(dto: coverOnly).heroURL == "cover")
        #expect(try GameDetail(dto: decode(#"{"id":1,"name":"A"}"#)).heroURL == nil)
    }

    @Test func bringsTheZeroToHundredRatingDownToTheTenPointScale() throws {
        #expect(try GameDetail(dto: decode(#"{"id":1,"name":"A","total_rating":86.0}"#)).rating == 8.6)
        #expect(try GameDetail(dto: decode(#"{"id":1,"name":"A","aggregated_rating":90.0}"#)).rating == 9.0)
        #expect(try GameDetail(dto: decode(#"{"id":1,"name":"A","rating":70.0}"#)).rating == 7.0)
    }

    @Test func leavesTheRatingNilForAnUnreleasedGame() throws {
        #expect(try GameDetail(dto: decode(#"{"id":1,"name":"A"}"#)).rating == nil)
    }

    @Test func mergesGenresAndThemesIntoOneChipList() throws {
        let dto = try decode("""
        {"id":1,"name":"A","genres":[{"name":"RPG"},{"name":"Adventure"}],
         "themes":[{"name":"Fantasy"},{"id":9}]}
        """)

        #expect(GameDetail(dto: dto).genres == ["RPG", "Adventure", "Fantasy"])
    }

    @Test func prefersThePlatformAbbreviationWhenIGDBSendsOne() throws {
        let dto = try decode("""
        {"id":1,"name":"A","platforms":[
          {"name":"PlayStation 5","slug":"ps5","abbreviation":"PS5"},
          {"name":"Nintendo Switch 2","slug":"switch-2"}
        ]}
        """)

        #expect(GameDetail(dto: dto).platforms == ["PS5", "Switch 2"])
    }

    @Test func onlyListsTheSpecificationsIGDBActuallyReturned() throws {
        let dto = try decode("""
        {"id":1,"name":"A","game_engines":[{"name":"Unreal"}],
         "involved_companies":[{"company":{"name":"FromSoftware"},"developer":true,"publisher":false}],
         "release_dates":[{"human":"Feb 25, 2022"}]}
        """)
        let specs = GameDetail(dto: dto).specs

        #expect(specs.map(\.label) == ["Developer", "Released", "Engine"])
        #expect(specs.map(\.value) == ["FromSoftware", "Feb 25, 2022", "Unreal"])
    }

    @Test func fallsBackToTheSummaryChainForTheAboutText() throws {
        #expect(try GameDetail(dto: decode(#"{"id":1,"name":"A","summary":"s","storyline":"l"}"#)).about == "s")
        #expect(try GameDetail(dto: decode(#"{"id":1,"name":"A","storyline":"l"}"#)).about == "l")
        #expect(try GameDetail(dto: decode(#"{"id":1,"name":"A"}"#)).about == "No description available yet.")
    }

    @Test func showsTBAWhenTheGameHasNoReleaseDate() throws {
        #expect(try GameDetail(dto: decode(#"{"id":1,"name":"A"}"#)).year == "TBA")
        #expect(try GameDetail(dto: decode(#"{"id":1,"name":"A","first_release_date":1655294400}"#)).year == "2022")
    }
}
