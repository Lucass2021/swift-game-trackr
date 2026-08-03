import SwiftUI

enum AvatarPalette: String, CaseIterable, Identifiable {
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

    var start: Color {
        switch self {
        case .violet: .coverVioletStart
        case .emerald: .coverEmeraldStart
        case .crimson: .coverCrimsonStart
        case .indigo: .coverIndigoStart
        case .azure: .coverAzureStart
        case .cyan: .coverCyanStart
        case .pine: .coverPineStart
        }
    }

    var end: Color {
        switch self {
        case .violet: .coverVioletEnd
        case .emerald: .coverEmeraldEnd
        case .crimson: .coverCrimsonEnd
        case .indigo: .coverIndigoEnd
        case .azure: .coverAzureEnd
        case .cyan: .coverCyanEnd
        case .pine: .coverPineEnd
        }
    }

    static func matching(start: Color, end: Color) -> AvatarPalette {
        allCases.first { $0.start == start && $0.end == end } ?? .violet
    }
}
