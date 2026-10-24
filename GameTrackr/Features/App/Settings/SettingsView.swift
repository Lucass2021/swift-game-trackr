import SwiftUI

struct SettingsView: View {
    @Environment(AuthStore.self) private var authStore
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: SettingsViewModel
    @State private var showDeleteAlert = false
    @State private var showChangePassword = false

    init(notificationSettingsRepository: NotificationSettingsRepository, accountRepository: AccountRepository) {
        _viewModel = State(initialValue: SettingsViewModel(
            notificationSettingsRepository: notificationSettingsRepository,
            accountRepository: accountRepository
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            StatsTopBar(title: "Settings", onBack: { if !viewModel.isDeleting { dismiss() } })

            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.xl) {
                    SettingsNotificationsSection(
                        settings: viewModel.notificationSettings,
                        hasError: viewModel.hasError,
                        onToggle: { viewModel.onNotificationToggle($0, enabled: $1) },
                        onRetry: { Task { await viewModel.load() } }
                    )

                    GroupedSection(title: "Account") {
                        GroupedNavRow(icon: .shieldCheck, title: "Change password") {
                            showChangePassword = true
                        }
                    }

                    GroupedSection(title: "Danger zone") {
                        GroupedDestructiveRow(icon: .close, title: "Delete account", isLoading: viewModel.isDeleting) {
                            if !viewModel.isDeleting { showDeleteAlert = true }
                        }
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.xxl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toast(message: $viewModel.toastMessage)
        .task { await viewModel.loadIfNeeded() }
        .onChange(of: viewModel.isDeleted) { _, isDeleted in
            if isDeleted { authStore.logout() }
        }
        .navigationDestination(isPresented: $showChangePassword) {
            ChangePasswordView(repository: FakePasswordRepository())
        }
        .alert("Delete account?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { Task { await viewModel.deleteAccount() } }
        } message: {
            Text("This action cannot be undone. All your data, library, and stats will be permanently removed.")
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(
            notificationSettingsRepository: FakeNotificationSettingsRepository(),
            accountRepository: FakeAccountRepository()
        )
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
