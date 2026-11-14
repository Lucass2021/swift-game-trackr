import Foundation

nonisolated enum CoverPalette: String, CaseIterable, Identifiable {
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

    var title: String {
        rawValue.capitalized
    }

    private static let gradientOrder: [CoverPalette] = [.emerald, .crimson, .indigo, .azure, .violet, .cyan, .pine]

    static func forId(_ id: Int) -> CoverPalette {
        allCases[((id % allCases.count) + allCases.count) % allCases.count]
    }

    static func forGradientId(_ id: Int) -> CoverPalette {
        gradientOrder[abs(id) % gradientOrder.count]
    }
}
