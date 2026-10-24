import SwiftUI

struct ProfileMenuView: View {
    @Binding var profile: Profile

    @Environment(AuthStore.self) private var authStore

    @State private var destination: ProfileMenuItem?

    private var state: ProfileMenuUiState {
        ProfileMenuUiState(
            isGuest: authStore.isGuest,
            userName: authStore.currentUser?.name,
            email: authStore.currentUser?.email
        )
    }

    var body: some View {
        let state = state
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    ProfileMenuAccountHeader(name: state.name, subtitle: state.subtitle)

                    if !state.accountItems.isEmpty {
                        ProfileMenuSection(items: state.accountItems) { destination = $0 }
                    }

                    ProfileMenuSection(items: state.appItems) { destination = $0 }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)
            }

            sessionButton(isGuest: state.isGuest)
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.sm)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .navigationTitle("Menu")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $destination) { destinationView($0) }
    }

    @ViewBuilder
    private func sessionButton(isGuest: Bool) -> some View {
        if isGuest {
            PrimaryButton(title: "Create an account") { authStore.logout() }
        } else {
            SecondaryButton(title: "Sign out") { authStore.logout() }
        }
    }

    @ViewBuilder
    private func destinationView(_ item: ProfileMenuItem) -> some View {
        switch item {
        case .editProfile: EditProfileView(profile: $profile)
        case .stats: StatsView()
        case .achievements: AchievementsView()
        case .settings: SettingsView()
        case .help: HelpView()
        case .about: AboutView()
        }
    }
}

#Preview {
    @Previewable @State var profile = ProfileMockData.profile
    NavigationStack {
        ProfileMenuView(profile: $profile)
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
