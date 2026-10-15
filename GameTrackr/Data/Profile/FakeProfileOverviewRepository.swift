struct FakeProfileOverviewRepository: ProfileOverviewRepository {
    func fetchMyOverview() async throws -> ProfileOverview {
        try await Task.sleep(for: FakeLatency.responseDelay)
        return ProfileOverview(
            breakdown: ProfileMockData.breakdown,
            favorites: ProfileMockData.favorites,
            currentlyPlaying: ProfileMockData.currentlyPlaying,
            activity: ProfileMockData.activity
        )
    }

    func fetchUserOverview(username _: String) async throws -> ProfileOverview {
        try await Task.sleep(for: FakeLatency.responseDelay)
        return ProfileOverview(
            breakdown: UserProfileMockData.breakdown,
            favorites: UserProfileMockData.favorites,
            currentlyPlaying: UserProfileMockData.currentlyPlaying,
            activity: UserProfileMockData.activity
        )
    }
}
