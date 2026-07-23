import SwiftUI

struct CommunityView: View {
    @State private var segment: CommunitySegment = .myFeed
    @State private var feedFilter = CommunityFeedFilter.latest.rawValue
    @State private var category = "All"
    @State private var feed = CommunityMockData.feed
    @State private var communities = CommunityMockData.all
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
                        communities: $communities,
                        onSelect: { selectedCommunity = $0 }
                    )
                }
            }

            if segment == .myFeed, !feed.isEmpty {
                CreatePostButton(action: { showCreateTopic = true })
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .fullScreenCover(isPresented: $showCreateTopic) {
            CreateTopicView(onPost: { feed.insert($0, at: 0) })
        }
        .navigationDestination(item: $selectedPost) { post in
            PostDetailView(post: post, onCommunitySelect: {
                selectedPost = nil
                selectedCommunity = CommunityMockData.detailCommunity
            })
        }
        .navigationDestination(item: $selectedCommunity) { community in
            CommunityDetailView(community: community, onPostSelect: { selectedPost = $0 })
        }
    }

    @ViewBuilder
    private var feedContent: some View {
        if feed.isEmpty {
            CommunityEmptyState(
                icon: .community,
                title: "Your feed is quiet",
                message: "Join a community to see posts from other players here.",
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

                    ForEach(Array(feed.enumerated()), id: \.element.id) { index, post in
                        CommunityPostCard(
                            post: post,
                            onSelect: { selectedPost = post },
                            onLike: { toggleLike(post) },
                            onComment: { selectedPost = post },
                            onBookmark: { toggleBookmark(post) }
                        )

                        if index == 0 {
                            SuggestedCommunityCard(
                                community: CommunityMockData.suggested,
                                onSelect: { selectedCommunity = CommunityMockData.suggested },
                                onJoin: {}
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 96)
            }
        }
    }

    private func toggleLike(_ post: CommunityPost) {
        guard let index = feed.firstIndex(where: { $0.id == post.id }) else { return }
        feed[index].isLiked.toggle()
        feed[index].likes += feed[index].isLiked ? 1 : -1
    }

    private func toggleBookmark(_ post: CommunityPost) {
        guard let index = feed.firstIndex(where: { $0.id == post.id }) else { return }
        feed[index].isBookmarked.toggle()
    }
}

#Preview {
    NavigationStack {
        CommunityView()
    }
    .preferredColorScheme(.dark)
}
