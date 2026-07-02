import SwiftUI

struct ProfileMenuView: View {
    @Environment(AuthStore.self) private var authStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                accountHeader

                menuSection([
                    .init(icon: "person.crop.circle", title: "Edit profile"),
                    .init(icon: "square.grid.2x2", title: "My collection"),
                    .init(icon: "list.bullet.rectangle", title: "My lists"),
                    .init(icon: "rosette", title: "Achievements")
                ])

                menuSection([
                    .init(icon: "gearshape", title: "Settings"),
                    .init(icon: "questionmark.circle", title: "Help & feedback"),
                    .init(icon: "info.circle", title: "About")
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
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 44))
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
                        Image(systemName: item.icon)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Color.appPrimary)
                            .frame(width: 24)
                        Text(item.title)
                            .font(.appLabel(16))
                            .foregroundStyle(Color.appTextPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
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
    let icon: String
    let title: String
}

#Preview {
    NavigationStack {
        ProfileMenuView()
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
