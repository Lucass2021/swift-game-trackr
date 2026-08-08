import SwiftUI

struct CommunityView: View {
    @State private var viewModel = CommunityViewModel()
    @State private var segment: CommunitySegment = .myFeed
    @State private var feedFilter = CommunityFeedFilter.latest.rawValue
    @State private var category = "All"
    @State private var selectedPost: CommunityPost?
    @State private var selectedCommunity: Community?
    @State private var showCreateTopic = false

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
                    DiscoverCommunitiesView(
                        category: $category,
                        communities: viewModel.communities,
                        onSelect: { selectedCommunity = $0 },
                        onJoin: { viewModel.toggleJoin($0) }
                    )
                }
            }

            if segment == .myFeed {
                CreatePostButton(action: { showCreateTopic = true })
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .task { await viewModel.loadFeed() }
        .task { await viewModel.loadCommunities() }
        .fullScreenCover(isPresented: $showCreateTopic) {
            CreateTopicView(viewModel: viewModel)
        }
        .navigationDestination(item: $selectedPost) { post in
            PostDetailView(post: post, onCommunitySelect: {
                selectedPost = nil
                if let id = post.communityId,
                   let community = viewModel.communities.first(where: { $0.id == id })
                {
                    selectedCommunity = community
                }
            })
        }
        .navigationDestination(item: $selectedCommunity) { community in
            CommunityDetailView(community: community, onPostSelect: { selectedPost = $0 })
        }
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
                            onSelect: { selectedPost = post },
                            onLike: { viewModel.toggleLike(post) },
                            onComment: { selectedPost = post },
                            onBookmark: { viewModel.toggleBookmark(post) }
                        )

                        if index == 0, let suggested = viewModel.communities.first(where: { !$0.isJoined }) {
                            SuggestedCommunityCard(
                                community: suggested,
                                onSelect: { selectedCommunity = suggested },
                                onJoin: { viewModel.toggleJoin(suggested) }
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 96)
            }
            .refreshable {
                await viewModel.loadFeed()
                await viewModel.loadCommunities()
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
