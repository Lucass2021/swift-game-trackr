import SwiftUI

private enum Constants {
    static let floatingInset: CGFloat = 16
}

struct CommunityDetailView: View {
    let community: Community
    var onPostSelect: (CommunityPost) -> Void = { _ in }
    var onDelete: () -> Void = {}

    @Environment(AuthStore.self) private var authStore
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CommunityDetailViewModel
    @State private var showCreateTopic = false
    @State private var selectedUser: UserProfile?
    private let repository: CommunityRepository
    private let postUpdates: PostUpdates

    init(
        community: Community,
        onPostSelect: @escaping (CommunityPost) -> Void = { _ in },
        onDelete: @escaping () -> Void = {},
        repository: CommunityRepository = RemoteCommunityRepository(),
        feedRepository: CommunityFeedRepository,
        postUpdates: PostUpdates,
        communityUpdates: CommunityUpdates
    ) {
        self.community = community
        self.onPostSelect = onPostSelect
        self.onDelete = onDelete
        self.repository = repository
        self.postUpdates = postUpdates
        _viewModel = State(initialValue: CommunityDetailViewModel(
            community: community,
            repository: repository,
            feedRepository: feedRepository,
            postUpdates: postUpdates,
            communityUpdates: communityUpdates
        ))
    }

    private var isOwner: Bool {
        community.authorId != nil && community.authorId == authStore.currentUser?.id
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            CommunityDetailContent(
                community: community,
                viewModel: viewModel,
                isGuest: authStore.isGuest,
                isOwner: isOwner,
                onPostSelect: onPostSelect,
                onCreatePost: { showCreateTopic = true },
                onMemberSelect: { member in
                    selectedUser = UserProfile(
                        handle: member.author,
                        avatarStart: member.avatarStart,
                        avatarEnd: member.avatarEnd
                    )
                }
            )

            if viewModel.tab == .posts, viewModel.isJoined, !authStore.isGuest {
                CreatePostButton(action: { showCreateTopic = true })
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .task { await viewModel.loadIfNeeded() }
        .fullScreenCover(isPresented: $showCreateTopic) {
            CreateTopicView(community: community, repository: repository, postUpdates: postUpdates)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(item: $selectedUser) { user in
            UserProfileView(user: user)
        }
        .overlay(alignment: .topLeading) {
            CommunityDetailFloatingButton(icon: .back, label: "Back") { dismiss() }
                .padding(.leading, Constants.floatingInset)
        }
        .overlay(alignment: .topTrailing) {
            if isOwner {
                CommunityDetailOwnerMenu(onDeleteRequest: { viewModel.onDeleteRequest() })
                    .padding(.trailing, Constants.floatingInset)
            }
        }
        .alert("Leave this community?", isPresented: $viewModel.showLeaveConfirmation) {
            Button("Leave", role: .destructive) { Task { await viewModel.onLeaveConfirmed() } }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You'll stop seeing its posts in your feed. You can join again anytime.")
        }
        .alert("Delete this community?", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Delete", role: .destructive) { Task { await viewModel.onDeleteConfirmed() } }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes the community and every post inside it. This can't be undone.")
        }
        .toast(message: $viewModel.toastMessage)
        .onChange(of: viewModel.isDeleted) { _, isDeleted in
            guard isDeleted else { return }
            onDelete()
            dismiss()
        }
        .ignoresSafeArea(edges: .top)
    }
}

#Preview("Signed in") {
    NavigationStack {
        CommunityDetailView(
            community: CommunityMockData.detailCommunity,
            repository: FakeCommunityRepository(latency: .zero),
            feedRepository: FakeCommunityFeedRepository(
                remote: FakeCommunityRepository(latency: .zero),
                latency: .zero
            ),
            postUpdates: PostUpdates(),
            communityUpdates: CommunityUpdates()
        )
    }
    .environment(AuthStore())
    .environment(LibraryDependencies())
    .preferredColorScheme(.dark)
}

#Preview("Error") {
    NavigationStack {
        CommunityDetailView(
            community: CommunityMockData.detailCommunity,
            repository: FakeCommunityRepository(failure: APIError.networkFailure, latency: .zero),
            feedRepository: FakeCommunityFeedRepository(
                remote: FakeCommunityRepository(latency: .zero),
                latency: .zero
            ),
            postUpdates: PostUpdates(),
            communityUpdates: CommunityUpdates()
        )
    }
    .environment(AuthStore())
    .environment(LibraryDependencies())
    .preferredColorScheme(.dark)
}
