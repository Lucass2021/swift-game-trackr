import SwiftUI

struct ProfileMenuView: View {
    @Binding var profile: Profile

    @Environment(AuthStore.self) private var authStore
    @Environment(\.dismiss) private var dismiss

    @State private var showStats = false
    @State private var showEditProfile = false

    private var accountName: String {
        guard !authStore.isGuest else { return "Guest" }
        return authStore.currentUser?.name ?? profile.name
    }

    private var accountSubtitle: String {
        guard !authStore.isGuest else { return "Not signed in" }
        return authStore.currentUser?.email ?? profile.username
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    accountHeader

                    if !authStore.isGuest {
                        menuSection([
                            .init(icon: .editProfile, title: "Edit profile", action: { showEditProfile = true }),
                            .init(icon: .chart, title: "My stats", action: { showStats = true }),
                            .init(icon: .medal, title: "Achievements")
                        ])
                    }

                    menuSection([
                        .init(icon: .settings, title: "Settings"),
                        .init(icon: .help, title: "Help & feedback"),
                        .init(icon: .info, title: "About")
                    ])
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }

            sessionSection
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .navigationTitle("Menu")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showStats) { StatsView() }
        .navigationDestination(isPresented: $showEditProfile) { EditProfileView(profile: $profile) }
    }

    private var accountHeader: some View {
        HStack(spacing: 14) {
            AppIconView(icon: .avatar, filled: true, size: 44)
                .foregroundStyle(Color.appTextSecondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(accountName)
                    .font(.appHeadline(18))
                    .foregroundStyle(Color.appTextPrimary)

                if !accountSubtitle.isEmpty {
                    Text(accountSubtitle)
                        .font(.appBody(14))
                        .foregroundStyle(Color.appTextSecondary)
                }
            }

            Spacer()
        }
        .padding(16)
        .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: 16))
    }

    private func menuSection(_ items: [MenuItem]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                Button(action: item.action) {
                    HStack(spacing: 14) {
                        AppIconView(icon: item.icon, size: 20)
                            .foregroundStyle(Color.appPrimary)
                            .frame(width: 24)
                        Text(item.title)
                            .font(.appLabel(16))
                            .foregroundStyle(Color.appTextPrimary)
                        Spacer()
                        AppIconView(icon: .forward, size: 16)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 15)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PressableButtonStyle())

                if index < items.count - 1 {
                    Divider()
                        .overlay(Color.appOutline)
                        .padding(.leading, 54)
                }
            }
        }
        .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private var sessionSection: some View {
        if authStore.isGuest {
            VStack(spacing: 14) {
                PrimaryButton(title: "Create an account") { authStore.logout() }
                SecondaryButton(title: "Exit guest mode") { authStore.logout() }
            }
        } else {
            SecondaryButton(title: "Sign out") { authStore.logout() }
        }
    }
}

private struct MenuItem: Identifiable {
    let id = UUID()
    let icon: AppIcon
    let title: String
    var action: () -> Void = {}
}

#Preview {
    @Previewable @State var profile = ProfileMockData.profile
    NavigationStack {
        ProfileMenuView(profile: $profile)
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
