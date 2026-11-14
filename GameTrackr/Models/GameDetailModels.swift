import Foundation

nonisolated struct GameScreenshot: Identifiable {
    let id = UUID()
    let url: String?
    let cover: CoverPalette

    init(url: String? = nil, cover: CoverPalette) {
        self.url = url
        self.cover = cover
    }
}

nonisolated struct GameSpec: Identifiable {
    let id = UUID()
    let label: String
    let value: String
}

nonisolated struct GameDetail {
    let title: String
    let year: String
    let rating: Double?
    let platforms: [String]
    let genres: [String]
    let cover: CoverPalette
    let heroURL: String?
    let screenshots: [GameScreenshot]
    let about: String
    let specs: [GameSpec]
}

nonisolated extension GameDetail {
    init(dto: GameDetailDTO) {
        let palette = CoverPalette.forGradientId(dto.id)
        let releaseDate = dto.firstReleaseDate.map { Date(timeIntervalSince1970: TimeInterval($0)) }

        title = dto.name
        year = releaseDate.map { Calendar.current.component(.year, from: $0).description } ?? "TBA"
        rating = (dto.totalRating ?? dto.aggregatedRating ?? dto.rating).map { $0 / 10 }
        platforms = (dto.platforms ?? []).compactMap {
            $0.abbreviation ?? PlatformLabel.short(slug: $0.slug, name: $0.name)
        }
        genres = Self.names(dto.genres) + Self.names(dto.themes)
        cover = palette
        heroURL = dto.screenshots?.first?.url ?? dto.artworks?.first?.url ?? dto.cover?.url
        screenshots = (dto.screenshots ?? []).map {
            GameScreenshot(url: $0.url, cover: palette)
        }
        about = dto.summary ?? dto.storyline ?? "No description available yet."
        specs = Self.specs(dto: dto, releaseDate: releaseDate)
    }

    private static func names(_ items: [GameNamedDTO]?) -> [String] {
        (items ?? []).compactMap(\.name)
    }

    private static func specs(dto: GameDetailDTO, releaseDate: Date?) -> [GameSpec] {
        let companies = dto.involvedCompanies ?? []
        let developer = companies.first { $0.developer == true }?.company?.name
        let publisher = companies.first { $0.publisher == true }?.company?.name
        let release = dto.releaseDates?.first?.human ?? releaseDate.map {
            $0.formatted(.dateTime.month(.abbreviated).day().year())
        }

        let candidates: [(String, String?)] = [
            ("Developer", developer),
            ("Publisher", publisher),
            ("Released", release),
            ("Engine", names(dto.gameEngines).first),
            ("Modes", names(dto.gameModes).joined(separator: ", ").nilIfEmpty),
            ("Perspective", names(dto.playerPerspectives).joined(separator: ", ").nilIfEmpty)
        ]

        return candidates.compactMap { label, value in
            value.map { GameSpec(label: label, value: $0) }
        }
    }
}

private nonisolated extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
