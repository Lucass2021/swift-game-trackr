import SwiftUI

struct UserProfileView: View {
    let user: UserProfile

    @Environment(AuthStore.self) private var authStore
    @Environment(\.dismiss) private var dismiss

    @State private var isFriend: Bool
    @State private var showStats = false
    @State private var showGameDetail = false
    @State private var toastMessage: String?

    init(user: UserProfile) {
        self.user = user
        _isFriend = State(initialValue: user.isFriend)
    }

    private var profile: Profile {
        UserProfileMockData.profile(for: user)
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showStats) {
            StatsView(ownerName: user.username)
        }
        .navigationDestination(isPresented: $showGameDetail) {
            GameDetailView()
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

            Button {} label: {
                AppIconView(icon: .overflow, size: 22)
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(width: 40, height: 40, alignment: .trailing)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("More options")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 26) {
                ProfileHeader(
                    profile: profile,
                    mode: .other(isFriend: isFriend),
                    onAddFriend: toggleFriend,
                    onMessage: gatedMessage
                )

                ProfileStatsBar(stats: profile.stats, onTap: { showStats = true })
                    .padding(.horizontal, 20)

                section("Breakdown") {
                    ProfileBreakdownSection(breakdown: UserProfileMockData.breakdown)
                        .padding(.horizontal, 20)
                }

                section("Favorites") {
                    ProfileFavoritesSection(
                        favorites: UserProfileMockData.favorites,
                        onSelect: { _ in showGameDetail = true }
                    )
                }

                section("Currently playing") {
                    VStack(spacing: 14) {
                        ForEach(UserProfileMockData.currentlyPlaying) { entry in
                            Button { showGameDetail = true } label: {
                                LibraryEntryRow(entry: entry)
                            }
                            .buttonStyle(PressableButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                }

                section("Recent activity") {
                    ProfileActivitySection(events: UserProfileMockData.activity)
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
        UserProfileView(user: UserProfile(
            name: "Ava Reyes",
            username: "@avareyes",
            avatarStart: .coverCyanStart,
            avatarEnd: .coverCyanEnd
        ))
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}

#Preview("Friend") {
    NavigationStack {
        UserProfileView(user: UserProfile(
            name: "Ava Reyes",
            username: "@avareyes",
            avatarStart: .coverCyanStart,
            avatarEnd: .coverCyanEnd,
            isFriend: true
        ))
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
