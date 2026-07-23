import SwiftUI

struct ProfileView: View {
    var profile: Profile = ProfileMockData.profile
    var breakdown: [StatusCount] = ProfileMockData.breakdown
    var favorites: [LibraryEntry] = ProfileMockData.favorites
    var currentlyPlaying: [LibraryEntry] = ProfileMockData.currentlyPlaying
    var activity: [ActivityEvent] = ProfileMockData.activity
    var onGameSelect: () -> Void = {}
    var onStatusSelect: (LibraryStatus) -> Void = { _ in }
    var onEditProfile: () -> Void = {}

    @Environment(AuthStore.self) private var authStore

    var body: some View {
        Group {
            if authStore.isGuest {
                guestState
            } else {
                content
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }

    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 26) {
                ProfileHeader(profile: profile, onEdit: onEditProfile)

                ProfileStatsBar(stats: profile.stats)
                    .padding(.horizontal, 20)

                section("Breakdown") {
                    ProfileBreakdownSection(breakdown: breakdown, onSelect: onStatusSelect)
                        .padding(.horizontal, 20)
                }

                section("Favorites") {
                    ProfileFavoritesSection(favorites: favorites, onSelect: { _ in onGameSelect() })
                }

                section("Currently playing", actionTitle: "View all") {
                    onStatusSelect(.playing)
                } content: {
                    VStack(spacing: 14) {
                        ForEach(currentlyPlaying) { entry in
                            Button(action: onGameSelect) {
                                LibraryEntryRow(entry: entry)
                            }
                            .buttonStyle(PressableButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                }

                section("Recent activity") {
                    ProfileActivitySection(events: activity)
                        .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 32)
        }
    }

    private var guestState: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            AppIconView(icon: .avatar, size: 56)
                .foregroundStyle(Color.appPrimary)
                .frame(width: 120, height: 120)
                .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                .shadow(color: Color.appPrimary.opacity(0.35), radius: 30)
                .subtleBounce()

            Text("Guest")
                .font(.appHeadline(24, weight: .heavy))
                .foregroundStyle(Color.appTextPrimary)
                .padding(.top, 28)

            Text("You're browsing as a guest. Create an account to build a public profile with your stats.")
                .font(.appBody(15))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
                .padding(.horizontal, 24)

            PrimaryButton(title: "Create an account") { authStore.logout() }
                .padding(.top, 28)
                .padding(.horizontal, 32)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func section(
        _ title: String,
        actionTitle: String? = nil,
        action: @escaping () -> Void = {},
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.appHeadline(20))
                    .foregroundStyle(Color.appTextPrimary)

                Spacer()

                if let actionTitle {
                    Button(action: action) {
                        Text(actionTitle)
                            .font(.appLabel(15))
                            .foregroundStyle(Color.appPrimary)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            .padding(.horizontal, 20)

            content()
        }
    }
}

#Preview("Signed in") {
    ProfileView()
        .environment(AuthStore())
        .preferredColorScheme(.dark)
}
