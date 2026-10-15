import SwiftUI

struct UserProfileView: View {
    let user: UserProfile
    var repository: ProfileOverviewRepository = FakeProfileOverviewRepository()

    @Environment(AuthStore.self) private var authStore
    @Environment(\.dismiss) private var dismiss

    @State private var isFriend: Bool
    @State private var showStats = false
    @State private var detailSlug: String?
    @State private var toastMessage: String?
    @State private var overview: ProfileOverview?

    init(user: UserProfile, repository: ProfileOverviewRepository = FakeProfileOverviewRepository()) {
        self.user = user
        self.repository = repository
        _isFriend = State(initialValue: user.isFriend)
    }

    private var profile: Profile {
        UserProfileMockData.profile(for: user)
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            if let overview {
                content(overview)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .task {
                        overview = try? await repository.fetchUserOverview(username: user.username)
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showStats) {
            StatsView(ownerName: user.username)
        }
        .navigationDestination(item: $detailSlug) { slug in
            GameDetailView(slug: slug)
        }
        .toast(message: $toastMessage)
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                AppIconView(icon: .back, size: 22)
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(width: 40, height: 40, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Back")

            Text(user.username)
                .font(.appHeadline(18))
                .foregroundStyle(Color.appTextPrimary)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private func content(_ overview: ProfileOverview) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 26) {
                ProfileHeader(
                    profile: profile,
                    mode: .other(isFriend: isFriend),
                    isGuest: authStore.isGuest,
                    shareText: "Check out \(user.name)'s gaming profile on GameTrackr!",
                    onAddFriend: toggleFriend,
                    onMessage: gatedMessage
                )

                ProfileStatsBar(stats: profile.stats, onTap: { showStats = true })
                    .padding(.horizontal, 20)

                section("Breakdown") {
                    ProfileBreakdownSection(breakdown: overview.breakdown)
                        .padding(.horizontal, 20)
                }

                section("Favorites") {
                    ProfileFavoritesSection(
                        favorites: overview.favorites,
                        onSelect: { detailSlug = $0.slug }
                    )
                }

                section("Currently playing") {
                    VStack(spacing: 14) {
                        ForEach(overview.currentlyPlaying) { entry in
                            Button { detailSlug = entry.slug } label: {
                                LibraryEntryRow(entry: entry)
                            }
                            .buttonStyle(PressableButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                }

                section("Recent activity") {
                    ProfileActivitySection(events: overview.activity)
                        .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 32)
        }
    }

    private func toggleFriend() {
        guard !authStore.isGuest else {
            toastMessage = "You're browsing as a guest. Create an account to add friends."
            return
        }
        isFriend.toggle()
    }

    private func gatedMessage() {
        guard !authStore.isGuest else {
            toastMessage = "You're browsing as a guest. Create an account to send messages."
            return
        }
    }

    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.appHeadline(20))
                .foregroundStyle(Color.appTextPrimary)
                .padding(.horizontal, 20)

            content()
        }
    }
}

#Preview("Not friend") {
    NavigationStack {
        UserProfileView(user: UserProfileMockData.user)
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}

#Preview("Friend") {
    NavigationStack {
        UserProfileView(user: UserProfileMockData.friend)
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
