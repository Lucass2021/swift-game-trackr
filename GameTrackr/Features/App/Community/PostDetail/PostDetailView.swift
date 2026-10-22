import SwiftUI

struct PostDetailView: View {
    let post: CommunityPost
    var onCommunitySelect: () -> Void = {}
    var onDelete: () -> Void = {}

    @Environment(AuthStore.self) private var authStore
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PostDetailViewModel
    @State private var selectedUser: UserProfile?

    init(
        post: CommunityPost,
        onCommunitySelect: @escaping () -> Void = {},
        onDelete: @escaping () -> Void = {},
        repository: CommunityRepository = RemoteCommunityRepository(),
        feedRepository: CommunityFeedRepository,
        postUpdates: PostUpdates
    ) {
        self.post = post
        self.onCommunitySelect = onCommunitySelect
        self.onDelete = onDelete
        _viewModel = State(initialValue: PostDetailViewModel(
            post: post,
            repository: repository,
            feedRepository: feedRepository,
            postUpdates: postUpdates
        ))
    }

    private var isOwnPost: Bool {
        authStore.currentUser?.id != nil && authStore.currentUser?.id == post.authorId
    }

    private var screenToast: Binding<String?> {
        Binding(
            get: { viewModel.showComments ? nil : viewModel.toastMessage },
            set: { viewModel.toastMessage = $0 }
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            PostDetailTopBar(
                isOwnPost: isOwnPost,
                onBack: { dismiss() },
                onDeleteRequest: { viewModel.onDeleteRequest() }
            )

            PostDetailContent(
                post: viewModel.post,
                commentCount: viewModel.commentCount,
                isGuest: authStore.isGuest,
                onAuthorSelect: {
                    selectedUser = UserProfile(
                        handle: post.author,
                        avatarStart: post.avatarStart,
                        avatarEnd: post.avatarEnd
                    )
                },
                onCommunitySelect: onCommunitySelect,
                onLike: { Task { await viewModel.onLike() } },
                onComment: { viewModel.onCommentsOpen() },
                onBookmark: { Task { await viewModel.onBookmark() } },
                onCreateAccount: { authStore.logout() }
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .task { await viewModel.loadIfNeeded() }
        .toast(message: screenToast)
        .sheet(isPresented: $viewModel.showComments) {
            PostCommentsSheet(viewModel: viewModel, isGuest: authStore.isGuest)
        }
        .navigationDestination(item: $selectedUser) { user in
            UserProfileView(user: user)
        }
        .alert("Delete post?", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Delete", role: .destructive) { Task { await viewModel.onDeleteConfirmed() } }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone. The post and all its comments will be permanently deleted.")
        }
        .onChange(of: viewModel.isDeleted) { _, isDeleted in
            guard isDeleted else { return }
            onDelete()
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        PostDetailView(
            post: CommunityMockData.detailPost,
            repository: FakeCommunityRepository(posts: [CommunityMockData.detailPost]),
            feedRepository: FakeCommunityFeedRepository(remote: FakeCommunityRepository()),
            postUpdates: PostUpdates()
        )
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
