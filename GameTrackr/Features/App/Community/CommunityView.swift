import SwiftUI

struct CommunityView: View {
    @Environment(AuthStore.self) private var authStore
    let dependencies: CommunityDependencies
    @State private var viewModel: CommunityViewModel
    @State private var segment: CommunitySegment = .myFeed
    @State private var selectedPost: CommunityPost?
    @State private var selectedCommunity: Community?
    @State private var showCreateTopic = false
    @State private var showCreateCommunity = false

    private var feedViewModel: CommunityFeedViewModel {
        dependencies.feedViewModel
    }

    init(dependencies: CommunityDependencies) {
        self.dependencies = dependencies
        _viewModel = State(initialValue: CommunityViewModel(
            repository: dependencies.repository,
            communityUpdates: dependencies.communityUpdates
        ))
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                CommunitySegmentControl(selection: $segment)
                    .padding(.top, Spacing.xxs)
                    .padding(.bottom, Spacing.md)

                switch segment {
                case .myFeed:
                    CommunityFeedContent(
                        viewModel: feedViewModel,
                        isGuest: authStore.isGuest,
                        onPostSelect: { selectedPost = $0 },
                        onCommunitySelect: { selectedCommunity = $0 },
                        onDiscover: { segment = .discover }
                    )
                case .discover:
                    CommunityDiscoverSegment(
                        viewModel: viewModel,
                        isGuest: authStore.isGuest,
                        currentUserId: authStore.currentUser?.id,
                        onCommunitySelect: { selectedCommunity = $0 },
                        onCreateAccount: { authStore.logout() }
                    )
                }
            }

            if !authStore.isGuest {
                CreatePostButton(
                    action: { if segment == .myFeed { showCreateTopic = true } else { showCreateCommunity = true } },
                    accessibilityLabel: segment == .myFeed ? "Create post" : "Create community"
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .task { await feedViewModel.loadIfNeeded() }
        .task { await viewModel.loadCommunities() }
        .toast(message: Bindable(feedViewModel).toastMessage)
        .fullScreenCover(isPresented: $showCreateTopic) {
            CreateTopicView(viewModel: viewModel, onCreated: { feedViewModel.onPostCreated($0) })
        }
        .fullScreenCover(isPresented: $showCreateCommunity) {
            CreateCommunityView(viewModel: viewModel, onCreated: { selectedCommunity = $0 })
        }
        .navigationDestination(item: $selectedPost) { post in
            PostDetailView(
                post: post,
                onCommunitySelect: {
                    selectedPost = nil
                    if let id = post.communityId, let community = viewModel.communities.first(where: { $0.id == id }) {
                        selectedCommunity = community
                    }
                },
                onDelete: { feedViewModel.onPostDeleted(post.id) },
                repository: dependencies.repository,
                feedRepository: dependencies.feedRepository,
                postUpdates: dependencies.postUpdates
            )
        }
        .navigationDestination(item: $selectedCommunity) { community in
            CommunityDetailView(
                community: community,
                onPostSelect: { selectedPost = $0 },
                onDelete: {
                    viewModel.removeCommunity(id: community.id)
                    feedViewModel.onCommunityRemoved(community.id)
                },
                repository: dependencies.repository,
                feedRepository: dependencies.feedRepository,
                postUpdates: dependencies.postUpdates,
                communityUpdates: dependencies.communityUpdates
            )
        }
    }
}

#Preview {
    NavigationStack {
        CommunityView(dependencies: CommunityDependencies(repository: FakeCommunityRepository(latency: .zero)))
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
