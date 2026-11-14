import Foundation

nonisolated enum SetupPalette: String, CaseIterable, Identifiable {
    case violet
    case emerald
    case crimson
    case indigo
    case azure
    case cyan
    case pine

    var id: String {
        rawValue
    }

    static func forId(_ id: Int) -> SetupPalette {
        allCases[((id % allCases.count) + allCases.count) % allCases.count]
    }

    var title: String {
        rawValue.capitalized
    }
}
