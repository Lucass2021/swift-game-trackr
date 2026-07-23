import SwiftUI

struct CommunityDetailView: View {
    let community: Community
    var onPostSelect: (CommunityPost) -> Void = { _ in }

    @Environment(\.dismiss) private var dismiss
    @State private var isJoined: Bool
    @State private var tab: CommunityDetailTab = .posts
    @State private var posts = CommunityMockData.communityPosts
    @State private var showCreateTopic = false

    init(community: Community, onPostSelect: @escaping (CommunityPost) -> Void = { _ in }) {
        self.community = community
        self.onPostSelect = onPostSelect
        _isJoined = State(initialValue: community.isJoined)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    CommunityDetailHeader(community: community)

                    Text(community.description)
                        .font(.appBody(15))
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 20)

                    actions

                    CommunityStatsBar(community: community)
                        .padding(.horizontal, 20)

                    CommunityDetailTabs(selection: $tab)

                    tabContent
                }
                .padding(.bottom, 96)
            }

            if tab == .posts, !posts.isEmpty {
                CreatePostButton(action: { showCreateTopic = true })
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .fullScreenCover(isPresented: $showCreateTopic) {
            CreateTopicView(community: community, onPost: { posts.insert($0, at: 0) })
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .overlay(alignment: .topLeading) {
            floatingButton(icon: .back, label: "Back") { dismiss() }
                .padding(.leading, 16)
        }
        .overlay(alignment: .topTrailing) {
            floatingButton(icon: .overflow, label: "More options") {}
                .padding(.trailing, 16)
        }
        .ignoresSafeArea(edges: .top)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch tab {
        case .posts:
            if posts.isEmpty {
                CommunityEmptyState(
                    icon: .community,
                    title: "No posts yet",
                    message: "Start the first discussion in this community.",
                    actionTitle: "Create post",
                    action: { showCreateTopic = true }
                )
            } else {
                VStack(spacing: 16) {
                    ForEach(posts) { post in
                        CommunityPostCard(
                            post: post,
                            showsCommunityName: false,
                            onSelect: { onPostSelect(post) },
                            onLike: { toggleLike(post) },
                            onComment: { onPostSelect(post) },
                            onBookmark: { toggleBookmark(post) }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        case .about:
            CommunityAboutSection(community: community)
        case .members:
            CommunityMembersSection()
        }
    }

    private var actions: some View {
        HStack(spacing: 12) {
            JoinButton(isJoined: isJoined, expanded: true) {
                isJoined.toggle()
            }

            circleButton(icon: .notifications, label: "Community notifications")
            circleButton(icon: .share, label: "Share community")
        }
        .padding(.horizontal, 20)
    }

    private func circleButton(icon: AppIcon, label: String) -> some View {
        Button {} label: {
            AppIconView(icon: icon, size: 20)
                .foregroundStyle(Color.appTextPrimary)
                .frame(width: 50, height: 50)
                .background(Circle().stroke(Color.appOutline, lineWidth: 1))
                .contentShape(Circle())
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(label)
    }

    private func floatingButton(icon: AppIcon, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            AppIconView(icon: icon, size: 20)
                .foregroundStyle(Color.appTextPrimary)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.appBackground.opacity(0.55)))
                .contentShape(Circle())
        }
        .buttonStyle(PressableButtonStyle())
        .padding(.top, 60)
        .accessibilityLabel(label)
    }

    private func toggleLike(_ post: CommunityPost) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[index].isLiked.toggle()
        posts[index].likes += posts[index].isLiked ? 1 : -1
    }

    private func toggleBookmark(_ post: CommunityPost) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[index].isBookmarked.toggle()
    }
}

#Preview {
    NavigationStack {
        CommunityDetailView(community: CommunityMockData.detailCommunity)
    }
    .preferredColorScheme(.dark)
}
