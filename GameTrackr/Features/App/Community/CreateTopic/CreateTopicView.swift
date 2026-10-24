import SwiftUI

struct CreateTopicView: View {
    @Environment(AuthStore.self) private var authStore
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: CreateTopicViewModel
    @State private var showDiscardConfirm = false
    @FocusState private var focusedField: CreateTopicFocusField?

    init(community: Community? = nil, repository: CommunityRepository, postUpdates: PostUpdates) {
        _viewModel = State(initialValue: CreateTopicViewModel(
            community: community,
            repository: repository,
            postUpdates: postUpdates
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            FormHeader(
                title: "New post",
                actionLabel: "Post",
                closeLabel: "Close",
                savingLabel: "Posting",
                isSaving: viewModel.isSubmitting,
                onClose: requestClose,
                onAction: submit,
                closeIcon: .close,
                isActionVisible: !authStore.isGuest
            )

            if authStore.isGuest {
                EmptyState(
                    icon: .community,
                    title: "Posting needs an account",
                    message: "You're browsing as a guest. Create an account to start discussions in your communities.",
                    actionTitle: "Create an account",
                    onAction: { authStore.logout() }
                )
                .frame(maxHeight: .infinity)
            } else {
                CreateTopicForm(viewModel: viewModel, focusedField: $focusedField)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
        .toast(message: $viewModel.toastMessage)
        .task {
            guard !authStore.isGuest else { return }
            await viewModel.loadIfNeeded()
        }
        .alert("Discard this post?", isPresented: $showDiscardConfirm) {
            Button("Keep editing", role: .cancel) {}
            Button("Discard", role: .destructive) { dismiss() }
        }
    }

    private func requestClose() {
        if viewModel.createdPost != nil {
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
            guard await viewModel.submit() != nil else { return }
            dismiss()
        }
    }
}

#Preview {
    Color.appBackground
        .fullScreenCover(isPresented: .constant(true)) {
            CreateTopicView(
                community: CommunityMockData.all.first,
                repository: FakeCommunityRepository(),
                postUpdates: PostUpdates()
            )
        }
        .environment(AuthStore())
        .preferredColorScheme(.dark)
}
