import SwiftUI

struct CommunityView: View {
    @Environment(AuthStore.self) private var authStore
    @State private var viewModel = CommunityViewModel()
    @State private var segment: CommunitySegment = .myFeed
    @State private var feedFilter = CommunityFeedFilter.latest.rawValue
    @State private var category = "All"
    @State private var selectedPost: CommunityPost?
    @State private var selectedCommunity: Community?
    @State private var showCreateTopic = false
    @State private var showCreateCommunity = false
    @State private var communityToLeave: Community?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                CommunitySegmentControl(selection: $segment)
                    .padding(.top, 4)
                    .padding(.bottom, 14)

                switch segment {
                case .myFeed:
                    feedContent
                case .discover:
                    if authStore.isGuest {
                        Spacer()
                        CommunityEmptyState(
                            icon: .community,
                            title: "Account required",
                            message: "Create an account to discover\nand join communities.",
                            actionTitle: "Create an account",
                            action: { authStore.logout() }
                        )
                        Spacer()
                    } else {
                        DiscoverCommunitiesView(
                            category: $category,
                            communities: viewModel.communities,
                            currentUserId: authStore.currentUser?.id,
                            isLoadingMore: viewModel.communitiesPagination.isLoadingMore,
                            canLoadMore: viewModel.communitiesPagination.canLoadMore,
                            onSelect: { selectedCommunity = $0 },
                            onJoin: { community in
                                if community.isJoined {
                                    communityToLeave = community
                                } else {
                                    viewModel.joinCommunity(community)
                                }
                            },
                            onLoadMore: { Task { await viewModel.loadMoreCommunities() } }
                        )
                    }
                }
            }

            if !authStore.isGuest {
                switch segment {
                case .myFeed:
                    CreatePostButton(action: { showCreateTopic = true })
                case .discover:
                    CreatePostButton(
                        action: { showCreateCommunity = true },
                        accessibilityLabel: "Create community"
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .task { await viewModel.loadFeed() }
        .task { await viewModel.loadCommunities() }
        .fullScreenCover(isPresented: $showCreateTopic) {
            CreateTopicView(viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $showCreateCommunity) {
            CreateCommunityView(viewModel: viewModel, onCreated: { selectedCommunity = $0 })
        }
        .navigationDestination(item: $selectedPost) { post in
            PostDetailView(post: post, onCommunitySelect: {
                selectedPost = nil
                if let id = post.communityId,
                   let community = viewModel.communities.first(where: { $0.id == id })
                {
                    selectedCommunity = community
                }
            }, onDelete: {
                viewModel.feedPagination.removeAll { $0.id == post.id }
            })
        }
        .navigationDestination(item: $selectedCommunity) { community in
            CommunityDetailView(
                community: community,
                onPostSelect: { selectedPost = $0 },
                onDelete: { viewModel.removeCommunity(id: community.id) }
            )
        }
        .alert(
            "Leave this community?",
            isPresented: leaveAlertBinding,
            presenting: communityToLeave
        ) { community in
            Button("Leave", role: .destructive) { viewModel.leaveCommunity(community) }
            Button("Cancel", role: .cancel) {}
        } message: { _ in
            Text("You'll stop seeing its posts in your feed. You can join again anytime.")
        }
    }

    private var leaveAlertBinding: Binding<Bool> {
        Binding(
            get: { communityToLeave != nil },
            set: { if !$0 { communityToLeave = nil } }
        )
    }

    @ViewBuilder
    private var feedContent: some View {
        if let error = viewModel.feedError, viewModel.feed.isEmpty {
            Spacer()
            CommunityEmptyState(
                icon: .info,
                title: "Couldn't load feed",
                message: "Check your connection\nand try again.",
                actionTitle: "Try again",
                action: { Task { await viewModel.loadFeed() } }
            )
            Spacer()
        } else if viewModel.feed.isEmpty {
            Spacer()
            CommunityEmptyState(
                icon: .community,
                title: "Your feed is quiet",
                message: "Join a community to see posts\nfrom other players here.",
                actionTitle: "Discover communities",
                action: { segment = .discover }
            )
            Spacer()
        } else {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    CommunityChipRow(
                        titles: CommunityFeedFilter.allCases.map(\.rawValue),
                        selection: $feedFilter
                    )
                    .padding(.horizontal, -20)

                    ForEach(Array(viewModel.feed.enumerated()), id: \.element.id) { index, post in
                        CommunityPostCard(
                            post: post,
                            isGuest: authStore.isGuest,
                            onSelect: { selectedPost = post },
                            onLike: { viewModel.toggleLike(post) },
                            onComment: { selectedPost = post },
                            onBookmark: { viewModel.toggleBookmark(post) }
                        )
                        .onAppear {
                            if index >= viewModel.feed.count - 3 {
                                Task { await viewModel.loadMoreFeed() }
                            }
                        }
                    }

                    if viewModel.feedPagination.isLoadingMore {
                        LoadingMoreIndicator()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 96)
            }
            .refreshable {
                await viewModel.loadFeed(reset: true)
                await viewModel.loadCommunities(reset: true)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CommunityView()
    }
    .preferredColorScheme(.dark)
}
