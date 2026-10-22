enum CommunityFeedFilter: String, CaseIterable, Identifiable {
    case latest = "Latest"
    case topRated = "Top Rated"
    case following = "Following"

    var id: Self {
        self
    }
}
