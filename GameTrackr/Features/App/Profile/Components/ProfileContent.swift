import SwiftUI

struct ProfileContent: View {
    let overview: ProfileOverview
    let profile: Profile
    let setups: [SetupItem]
    var onGameSelect: (String) -> Void = { _ in }
    var onStatusSelect: (LibraryStatus?) -> Void = { _ in }
    var onEditProfile: () -> Void = {}
    var onViewStats: () -> Void = {}
    var onViewSetup: () -> Void = {}

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                ProfileHeader(
                    profile: profile,
                    onEdit: onEditProfile,
                    shareText: "Check out my gaming profile on GameTrackr!"
                )

                ProfileStatsBar(stats: overview.stats, onTap: onViewStats)
                    .padding(.horizontal, Spacing.lg)

                VStack(alignment: .leading, spacing: Spacing.sm) {
                    ProfileSectionHeader(title: "Breakdown")
                    ProfileBreakdownSection(breakdown: overview.breakdown, onSelect: onStatusSelect)
                        .padding(.horizontal, Spacing.lg)
                }

                VStack(alignment: .leading, spacing: Spacing.sm) {
                    ProfileSectionHeader(title: "Favorites", actionTitle: "View all") { onStatusSelect(nil) }
                    ProfileFavoritesSection(favorites: overview.favorites, onSelect: { onGameSelect($0.slug) })
                }

                VStack(alignment: .leading, spacing: Spacing.sm) {
                    ProfileSectionHeader(title: "Currently playing", actionTitle: "View all") {
                        onStatusSelect(.playing)
                    }
                    currentlyPlaying
                }

                VStack(alignment: .leading, spacing: Spacing.sm) {
                    ProfileSectionHeader(
                        title: "My Setup",
                        actionTitle: setups.isEmpty ? nil : "View all",
                        onAction: onViewSetup
                    )
                    ProfileSetupSection(setups: setups, onSelect: { _ in onViewSetup() }, onAdd: onViewSetup)
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
    ProfileContent(
        overview: ProfileMockData.overview,
        profile: ProfileMockData.profile,
        setups: ProfileMockData.setups
    )
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
