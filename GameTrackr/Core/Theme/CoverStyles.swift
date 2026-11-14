import SwiftUI

nonisolated extension CoverPalette {
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
}

nonisolated extension Game {
    var coverStart: Color {
        cover.start
    }

    var coverEnd: Color {
        cover.end
    }
}

nonisolated extension GameDetail {
    var coverStart: Color {
        cover.start
    }

    var coverEnd: Color {
        cover.end
    }
}

nonisolated extension GameScreenshot {
    var start: Color {
        cover.start
    }

    var end: Color {
        cover.end
    }
}

nonisolated extension LibraryEntry {
    var coverStart: Color {
        cover.start
    }

    var coverEnd: Color {
        cover.end
    }
}

nonisolated extension NewLibraryEntry {
    var coverStart: Color {
        cover.start
    }

    var coverEnd: Color {
        cover.end
    }
}

nonisolated extension GameAchievements {
    var coverStart: Color {
        cover.start
    }

    var coverEnd: Color {
        cover.end
    }
}
