import SwiftUI

struct UserProfileContent: View {
    let profile: Profile
    let overview: ProfileOverview
    let isFriend: Bool
    let isGuest: Bool
    let shareText: String
    var onFriendAction: () -> Void = {}
    var onMessage: () -> Void = {}
    var onGameSelect: (String) -> Void = { _ in }
    var onViewStats: () -> Void = {}

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                ProfileHeader(
                    profile: profile,
                    mode: .other(isFriend: isFriend),
                    isGuest: isGuest,
                    shareText: shareText,
                    onAddFriend: onFriendAction,
                    onMessage: onMessage
                )

                ProfileStatsBar(stats: overview.stats, onTap: onViewStats)
                    .padding(.horizontal, Spacing.lg)

                VStack(alignment: .leading, spacing: Spacing.sm) {
                    ProfileSectionHeader(title: "Breakdown")
                    ProfileBreakdownSection(breakdown: overview.breakdown)
                        .padding(.horizontal, Spacing.lg)
                }

                VStack(alignment: .leading, spacing: Spacing.sm) {
                    ProfileSectionHeader(title: "Favorites")
                    ProfileFavoritesSection(favorites: overview.favorites, onSelect: { onGameSelect($0.slug) })
                }

                VStack(alignment: .leading, spacing: Spacing.sm) {
                    ProfileSectionHeader(title: "Currently playing")
                    currentlyPlaying
                }

                VStack(alignment: .leading, spacing: Spacing.sm) {
                    ProfileSectionHeader(title: "Recent activity")
                    ProfileActivitySection(events: overview.activity)
                        .padding(.horizontal, Spacing.lg)
                }
            }
            .padding(.bottom, Spacing.xxl)
        }
    }

    private var currentlyPlaying: some View {
        VStack(spacing: Spacing.sm) {
            ForEach(overview.currentlyPlaying) { entry in
                Button { onGameSelect(entry.slug) } label: {
                    LibraryEntryRow(entry: entry)
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding(.horizontal, Spacing.lg)
    }
}

#Preview {
    UserProfileContent(
        profile: ProfileMockData.profile,
        overview: UserProfileMockData.overview,
        isFriend: false,
        isGuest: false,
        shareText: ""
    )
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
