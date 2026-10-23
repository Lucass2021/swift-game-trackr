import SwiftUI

actor FakeGameRepository: GameRepository {
    private static let games = [HomeMockData.sampleGame]

    private(set) var fetchNewReleasesCount = 0
    private(set) var fetchMostAnticipatedCount = 0
    private(set) var searchCount = 0
    private(set) var fetchGameCount = 0
    private(set) var lastSearch: String?
    private(set) var lastPlatformSlug: String?
    private let homeGames: [Game]
    private let searchResults: [Game]
    private var searchFailure: Error?
    private var newReleasesFailure: Error?
    private var mostAnticipatedFailure: Error?
    private var fetchGameFailure: Error?
    private let latency: Duration

    init(
        homeGames: [Game] = FakeGameRepository.games,
        searchResults: [Game] = FakeGameRepository.games,
        fetchGameFailure: Error? = nil,
        latency: Duration = FakeLatency.responseDelay
    ) {
        self.homeGames = homeGames
        self.searchResults = searchResults
        self.fetchGameFailure = fetchGameFailure
        self.latency = latency
    }

    static let gameDetail = GameDetail(
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
        fetchNewReleasesCount += 1
        try await Task.sleep(for: latency)
        if let newReleasesFailure { throw newReleasesFailure }
        return Array(homeGames.prefix(limit))
    }

    func fetchMostAnticipated(limit: Int) async throws -> [Game] {
        fetchMostAnticipatedCount += 1
        try await Task.sleep(for: latency)
        if let mostAnticipatedFailure { throw mostAnticipatedFailure }
        return Array(homeGames.prefix(limit))
    }

    func setNewReleasesFailure(_ error: Error?) {
        newReleasesFailure = error
    }

    func setMostAnticipatedFailure(_ error: Error?) {
        mostAnticipatedFailure = error
    }

    func fetchGame(slug _: String) async throws -> GameDetail {
        fetchGameCount += 1
        try await Task.sleep(for: latency)
        if let fetchGameFailure { throw fetchGameFailure }
        return Self.gameDetail
    }

    func setFetchGameFailure(_ error: Error?) {
        fetchGameFailure = error
    }

    func fetchAllNewReleases(page: Int, perPage: Int, search: String?, platformSlug: String?) async throws
        -> Page<Game>
    {
        try await self.search(page: page, perPage: perPage, search: search, platformSlug: platformSlug)
    }

    func fetchAllMostAnticipated(page: Int, perPage: Int, search: String?, platformSlug: String?) async throws
        -> Page<Game>
    {
        try await self.search(page: page, perPage: perPage, search: search, platformSlug: platformSlug)
    }

    func searchGames(page: Int, perPage: Int, search: String?, platformSlug: String?) async throws -> Page<Game> {
        try await self.search(page: page, perPage: perPage, search: search, platformSlug: platformSlug)
    }

    func setSearchFailure(_ error: Error?) {
        searchFailure = error
    }

    private func search(page: Int, perPage: Int, search: String?, platformSlug: String?) async throws -> Page<Game> {
        searchCount += 1
        lastSearch = search
        lastPlatformSlug = platformSlug
        try await Task.sleep(for: latency)
        if let searchFailure { throw searchFailure }
        return fakePage(items: searchResults, page: page, perPage: perPage)
    }

    func fetchPlatforms() async throws -> [GamePlatform] {
        try await Task.sleep(for: FakeLatency.responseDelay)
        return HomeMockData.platforms
    }
}
