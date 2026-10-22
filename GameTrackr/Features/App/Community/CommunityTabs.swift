import SwiftUI

enum CommunitySegment: String, CaseIterable, Identifiable {
    case myFeed = "Feed"
    case discover = "Discover"

    var id: Self {
        self
    }
}

enum CommunityDetailTab: String, CaseIterable, Identifiable {
    case posts = "Posts"
    case about = "About"
    case members = "Members"

    var id: Self {
        self
    }
}
