import SwiftUI

struct ProfileMenuView: View {
    @Environment(AuthStore.self) private var authStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                accountHeader

                menuSection([
                    .init(icon: .editProfile, title: "Edit profile"),
                    .init(icon: .grid, title: "My collection"),
                    .init(icon: .list, title: "My lists"),
                    .init(icon: .medal, title: "Achievements")
                ])

                menuSection([
                    .init(icon: .settings, title: "Settings"),
                    .init(icon: .help, title: "Help & feedback"),
                    .init(icon: .info, title: "About")
                ])

                sessionSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .navigationTitle("Menu")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var accountHeader: some View {
        HStack(spacing: 14) {
            AppIconView(icon: .avatar, filled: true, size: 44)
                .foregroundStyle(Color.appTextSecondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(authStore.isGuest ? "Guest" : (authStore.currentUser?.name ?? "Profile"))
                    .font(.appHeadline(18))
                    .foregroundStyle(Color.appTextPrimary)
                Text(authStore.isGuest ? "Not signed in" : (authStore.currentUser?.email ?? ""))
                    .font(.appBody(14))
                    .foregroundStyle(Color.appTextSecondary)
            }

            Spacer()
        }
        .padding(16)
        .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: 16))
    }

    private func menuSection(_ items: [MenuItem]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                Button {} label: {
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
}

#Preview {
    NavigationStack {
        ProfileMenuView()
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
