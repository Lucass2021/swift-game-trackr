import SwiftUI

enum GamePlatform: String, CaseIterable, Identifiable {
    case pc = "PC"
    case playstation = "PlayStation"
    case xbox = "Xbox"
    case nintendo = "Nintendo"

    var id: Self {
        self
    }

    var igdbSlugs: [String] {
        switch self {
        case .pc: ["win", "linux", "mac", "dos", "browser"]
        case .playstation: ["ps", "ps2", "ps3", "ps4--1", "ps5", "psp", "psvita", "psvr", "psvr2"]
        case .xbox: ["xbox", "xbox360", "xboxone", "series-x-s"]
        case .nintendo:
            ["nes", "snes", "n64", "ngc", "wii", "wiiu", "gb", "gbc", "gba", "nds", "3ds", "switch", "switch-2"]
        }
    }
}

enum PlatformLabel {
    private static let abbreviations: [String: String] = [
        "win": "PC",
        "linux": "Linux",
        "mac": "Mac",
        "dos": "DOS",
        "browser": "Web",
        "ps5": "PS5",
        "ps4--1": "PS4",
        "ps3": "PS3",
        "ps2": "PS2",
        "psvita": "Vita",
        "psp": "PSP",
        "series-x": "Xbox Series",
        "series-x-s": "Xbox Series",
        "xboxone": "Xbox One",
        "xbox360": "Xbox 360",
        "switch": "Switch",
        "switch-2": "Switch 2",
        "wiiu": "Wii U",
        "3ds": "3DS",
        "ios": "iOS",
        "android": "Android"
    ]

    static func short(slug: String?, name: String?) -> String? {
        if let slug, let abbreviation = abbreviations[slug] {
            return abbreviation
        }
        guard let name else { return nil }
        return name.components(separatedBy: " (").first ?? name
    }
}

struct Game: Identifiable, Hashable {
    static func == (lhs: Game, rhs: Game) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id: Int
    let name: String
    let slug: String
    let summary: String?
    let releaseDate: Date?
    let rating: Double?
    let coverUrl: String?
    let platformNames: [String]
    let coverStart: Color
    let coverEnd: Color

    var year: String {
        guard let releaseDate else { return "TBA" }
        return Calendar.current.component(.year, from: releaseDate).description
    }

    var platformsLabel: String {
        guard !platformNames.isEmpty else { return "Platform TBA" }
        let visible = platformNames.prefix(3).joined(separator: ", ")
        let remaining = platformNames.count - 3
        return remaining > 0 ? "\(visible) +\(remaining)" : visible
    }

    init(
        id: Int,
        name: String,
        slug: String = "",
        summary: String? = nil,
        releaseDate: Date? = nil,
        rating: Double? = nil,
        coverUrl: String? = nil,
        platformNames: [String] = []
    ) {
        self.id = id
        self.name = name
        self.slug = slug
        self.summary = summary
        self.releaseDate = releaseDate
        self.rating = rating
        self.coverUrl = coverUrl
        self.platformNames = platformNames
        let colors = GradientPalette.pair(for: id)
        coverStart = colors.0
        coverEnd = colors.1
    }

    init(dto: GameDTO) {
        let dtoPlatforms = dto.platforms ?? []
        let labels = dtoPlatforms.compactMap { PlatformLabel.short(slug: $0.slug, name: $0.name) }

        self.init(
            id: dto.id,
            name: dto.name,
            slug: dto.slug ?? "",
            summary: dto.summary,
            releaseDate: dto.firstReleaseDate.map { Date(timeIntervalSince1970: TimeInterval($0)) },
            rating: dto.totalRating ?? dto.rating,
            coverUrl: dto.cover?.url,
            platformNames: labels.reduce(into: []) { unique, label in
                if !unique.contains(label) { unique.append(label) }
            }
        )
    }
}
