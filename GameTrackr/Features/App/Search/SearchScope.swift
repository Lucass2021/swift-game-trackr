import SwiftUI

enum SearchScope: Hashable {
    case all
    case newReleases
    case mostAnticipated

    var title: String {
        switch self {
        case .all: "Search"
        case .newReleases: "New Releases"
        case .mostAnticipated: "Most Anticipated"
        }
    }

    var isFiltered: Bool {
        self != .all
    }
}
