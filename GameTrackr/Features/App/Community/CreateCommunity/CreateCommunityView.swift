import SwiftUI

struct CreateCommunityView: View {
    var onCreated: (Community) -> Void = { _ in }

    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: CreateCommunityViewModel
    @State private var showDiscardConfirm = false
    @FocusState private var focusedField: CreateCommunityFocusField?

    init(repository: CommunityRepository, onCreated: @escaping (Community) -> Void = { _ in }) {
        self.onCreated = onCreated
        _viewModel = State(initialValue: CreateCommunityViewModel(repository: repository))
    }

    var body: some View {
        VStack(spacing: 0) {
            FormHeader(
                title: "New community",
                actionLabel: "Create",
                closeLabel: "Close",
                savingLabel: "Creating",
                isSaving: viewModel.isSubmitting,
                onClose: requestClose,
                onAction: submit,
                closeIcon: .close
            )
            CreateCommunityForm(viewModel: viewModel, focusedField: $focusedField)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
        .toast(message: $viewModel.toastMessage)
        .alert("Discard this community?", isPresented: $showDiscardConfirm) {
            Button("Keep editing", role: .cancel) {}
            Button("Discard", role: .destructive) { dismiss() }
        }
    }

    private func requestClose() {
        if viewModel.createdCommunity != nil {
            dismiss()
            return
        }
        guard !viewModel.isSubmitting else { return }
        focusedField = nil
        if viewModel.hasContent {
            showDiscardConfirm = true
        } else {
            dismiss()
        }
    }

    private func submit() {
        focusedField = nil
        Task {
            guard let created = await viewModel.submit() else { return }
            onCreated(created)
            dismiss()
        }
    }
}

#Preview {
    Color.appBackground
        .fullScreenCover(isPresented: .constant(true)) {
            CreateCommunityView(repository: FakeCommunityRepository())
        }
        .preferredColorScheme(.dark)
}
