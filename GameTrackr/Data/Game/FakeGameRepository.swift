import SwiftUI

struct FakeGameRepository: GameRepository {
    private static let games = [HomeMockData.sampleGame]

    private static let gameDetail = GameDetail(
        title: "Neon Ascent: Revival",
        year: "2024",
        rating: 4.8,
        platforms: ["PS5", "PC"],
        genres: ["Action RPG", "Open World", "Cyberpunk"],
        coverStart: .coverVioletStart,
        coverEnd: .coverVioletEnd,
        heroURL: nil,
        screenshots: [
            GameScreenshot(start: .coverIndigoStart, end: .coverIndigoEnd),
            GameScreenshot(start: .coverCyanStart, end: .coverCyanEnd),
            GameScreenshot(start: .coverCrimsonStart, end: .coverCrimsonEnd),
            GameScreenshot(start: .coverEmeraldStart, end: .coverEmeraldEnd)
        ],
        about: """
        Neon Ascent: Revival is the definitive next-gen cyberpunk experience. Set in \
        the sprawling vertical megacity of Aethelgard, players take on the role of a \
        rogue netrunner untangling a conspiracy that reaches from the neon-drenched \
        undercity to the corporate spires above.
        """,
        specs: [
            GameSpec(label: "Developer", value: "Void Interactive"),
            GameSpec(label: "Publisher", value: "Nova Games"),
            GameSpec(label: "Released", value: "Mar 14, 2024"),
            GameSpec(label: "Modes", value: "Single player, Co-operative")
        ]
    )

    func fetchNewReleases(limit: Int) async throws -> [Game] {
        try await Task.sleep(for: FakeLatency.responseDelay)
        return Array(Self.games.prefix(limit))
    }

    func fetchMostAnticipated(limit: Int) async throws -> [Game] {
        try await Task.sleep(for: FakeLatency.responseDelay)
        return Array(Self.games.prefix(limit))
    }

    func fetchGame(slug _: String) async throws -> GameDetail {
        try await Task.sleep(for: FakeLatency.responseDelay)
        return Self.gameDetail
    }

    func fetchAllNewReleases(page: Int, perPage: Int, search _: String?, platformSlug _: String?) async throws
        -> Page<Game>
    {
        try await Task.sleep(for: FakeLatency.responseDelay)
        return fakePage(items: Self.games, page: page, perPage: perPage)
    }

    func fetchAllMostAnticipated(page: Int, perPage: Int, search _: String?, platformSlug _: String?) async throws
        -> Page<Game>
    {
        try await Task.sleep(for: FakeLatency.responseDelay)
        return fakePage(items: Self.games, page: page, perPage: perPage)
    }

    func searchGames(page: Int, perPage: Int, search _: String?, platformSlug _: String?) async throws -> Page<Game> {
        try await Task.sleep(for: FakeLatency.responseDelay)
        return fakePage(items: Self.games, page: page, perPage: perPage)
    }

    func fetchPlatforms() async throws -> [GamePlatform] {
        try await Task.sleep(for: FakeLatency.responseDelay)
        return HomeMockData.platforms
    }
}
