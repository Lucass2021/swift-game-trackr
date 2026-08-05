import SwiftUI

struct SettingsView: View {
    @Environment(AuthStore.self) private var authStore
    @Environment(\.dismiss) private var dismiss

    @State private var pushNotifications = true
    @State private var friendRequests = true
    @State private var communityReplies = true
    @State private var showDeleteAlert = false
    @State private var showChangePassword = false

    var body: some View {
        VStack(spacing: 0) {
            StatsTopBar(title: "Settings", onBack: { dismiss() })

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    section("Notifications") {
                        toggleRow(icon: .notifications, title: "Push notifications", isOn: $pushNotifications)
                        sectionDivider
                        toggleRow(icon: .addFriend, title: "Friend requests", isOn: $friendRequests)
                        sectionDivider
                        toggleRow(icon: .comment, title: "Community replies", isOn: $communityReplies)
                    }

                    section("Account") {
                        navRow(icon: .shieldCheck, title: "Change password") {
                            showChangePassword = true
                        }
                    }

                    section("Danger zone") {
                        destructiveRow(icon: .close, title: "Delete account") {
                            showDeleteAlert = true
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showChangePassword) { ChangePasswordView() }
        .alert("Delete account?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { authStore.logout() }
        } message: {
            Text("This action cannot be undone. All your data, library, and stats will be permanently removed.")
        }
    }

    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.appLabel(13))
                .foregroundStyle(Color.appTextSecondary)
                .textCase(.uppercase)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                content()
            }
            .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private var sectionDivider: some View {
        Divider()
            .overlay(Color.appOutline)
            .padding(.leading, 54)
    }

    private func toggleRow(icon: AppIcon, title: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 14) {
            AppIconView(icon: icon, size: 20)
                .foregroundStyle(Color.appPrimary)
                .frame(width: 24)

            Text(title)
                .font(.appLabel(16))
                .foregroundStyle(Color.appTextPrimary)

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color.appPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }

    private func navRow(icon: AppIcon, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                AppIconView(icon: icon, size: 20)
                    .foregroundStyle(Color.appPrimary)
                    .frame(width: 24)

                Text(title)
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
    }

    private func destructiveRow(icon: AppIcon, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                AppIconView(icon: icon, size: 20)
                    .foregroundStyle(Color.appTertiary)
                    .frame(width: 24)

                Text(title)
                    .font(.appLabel(16))
                    .foregroundStyle(Color.appTertiary)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
