import SwiftUI

struct EditProfileView: View {
    @Binding var profile: Profile

    @Environment(\.dismiss) private var dismiss
    @Environment(AuthStore.self) private var authStore

    @State private var viewModel: EditProfileViewModel
    @State private var showDiscardConfirm = false
    @FocusState private var focusedField: EditProfileFocusField?

    private let repository: ProfileRepository

    init(profile: Binding<Profile>, repository: ProfileRepository = RemoteProfileRepository()) {
        _profile = profile
        self.repository = repository
        _viewModel = State(initialValue: EditProfileViewModel(profile: profile.wrappedValue, repository: repository))
    }

    var body: some View {
        VStack(spacing: 0) {
            FormHeader(
                title: "Edit profile",
                actionLabel: "Save",
                closeLabel: "Back",
                savingLabel: "Saving",
                isSaving: viewModel.isSaving,
                onClose: requestClose,
                onAction: save
            )
            EditProfileForm(viewModel: viewModel, focusedField: $focusedField)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            let presented = EditProfileViewModel(profile: profile, repository: repository)
            viewModel = presented
            await presented.loadColorsIfNeeded()
        }
        .toast(message: $viewModel.toastMessage)
        .alert("Discard your changes?", isPresented: $showDiscardConfirm) {
            Button("Keep editing", role: .cancel) {}
            Button("Discard", role: .destructive) { dismiss() }
        }
    }

    private func requestClose() {
        if viewModel.savedProfile != nil {
            dismiss()
            return
        }
        guard !viewModel.isSaving else { return }
        focusedField = nil
        if viewModel.hasChanges {
            showDiscardConfirm = true
        } else {
            dismiss()
        }
    }

    private func save() {
        focusedField = nil
        Task {
            guard let updated = await viewModel.save(authStore: authStore) else { return }
            profile = updated
            dismiss()
        }
    }
}

#Preview {
    @Previewable @State var profile = ProfileMockData.profile
    NavigationStack {
        EditProfileView(profile: $profile, repository: FakeProfileRepository())
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
