import SwiftUI

struct CommunityDetailView: View {
    let community: Community
    var onPostSelect: (CommunityPost) -> Void = { _ in }

    @Environment(AuthStore.self) private var authStore
    @Environment(\.dismiss) private var dismiss
    @State private var isJoined: Bool
    @State private var tab: CommunityDetailTab = .posts
    @State private var postsPagination = PaginationState<CommunityPost>()
    @State private var members: [CommunityMember] = []
    @State private var showCreateTopic = false
    @State private var selectedUser: UserProfile?
    @State private var viewModel = CommunityViewModel()
    @State private var postsError = false

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
            .refreshable {
                await loadPosts(reset: true)
                await loadMembers()
            }

            if tab == .posts, isJoined, !authStore.isGuest {
                CreatePostButton(action: { showCreateTopic = true })
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .task { await loadPosts() }
        .task { await loadMembers() }
        .fullScreenCover(isPresented: $showCreateTopic) {
            CreateTopicView(viewModel: viewModel, community: community)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: showUserBinding) {
            if let selectedUser {
                UserProfileView(user: selectedUser)
            }
        }
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
            if postsError, postsPagination.items.isEmpty {
                CommunityEmptyState(
                    icon: .info,
                    title: "Couldn't load posts",
                    message: "Check your connection\nand try again.",
                    actionTitle: "Try again",
                    action: { Task { await loadPosts() } }
                )
            } else if postsPagination.items.isEmpty {
                CommunityEmptyState(
                    icon: .community,
                    title: "No posts yet",
                    message: isJoined
                        ? "Start the first discussion in this community."
                        : "Join this community to start posting.",
                    actionTitle: isJoined ? "Create post" : nil,
                    action: isJoined ? { showCreateTopic = true } : nil
                )
            } else {
                VStack(spacing: 16) {
                    ForEach(Array(postsPagination.items.enumerated()), id: \.element.id) { index, post in
                        CommunityPostCard(
                            post: post,
                            isGuest: authStore.isGuest,
                            showsCommunityName: false,
                            onSelect: { onPostSelect(post) },
                            onLike: { toggleLike(post) },
                            onComment: { onPostSelect(post) },
                            onBookmark: { toggleBookmark(post) }
                        )
                        .onAppear {
                            if index >= postsPagination.items.count - 3 {
                                Task { await loadPosts(reset: false) }
                            }
                        }
                    }

                    if postsPagination.isLoadingMore {
                        LoadingMoreIndicator()
                    }
                }
                .padding(.horizontal, 20)
            }
        case .about:
            CommunityAboutSection(community: community)
        case .members:
            CommunityMembersSection(members: members, onSelect: { member in
                selectedUser = UserProfile(
                    handle: member.author,
                    avatarStart: member.avatarStart,
                    avatarEnd: member.avatarEnd
                )
            })
        }
    }

    @ViewBuilder
    private var actions: some View {
        if !authStore.isGuest {
            HStack(spacing: 12) {
                JoinButton(isJoined: isJoined, expanded: true) {
                    toggleJoin()
                }

                circleButton(icon: .notifications, label: "Community notifications")

                ShareLink(item: "Join the \(community.name) community on GameTrackr!") {
                    AppIconView(icon: .share, size: 20)
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(width: 50, height: 50)
                        .background(Circle().stroke(Color.appOutline, lineWidth: 1))
                        .contentShape(Circle())
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("Share community")
            }
            .padding(.horizontal, 20)
        }
    }

    private var showUserBinding: Binding<Bool> {
        Binding(
            get: { selectedUser != nil },
            set: { if !$0 { selectedUser = nil } }
        )
    }

    private func loadPosts(reset: Bool = true) async {
        if reset {
            postsError = false
            postsPagination.reset()
        } else {
            guard postsPagination.canLoadMore else { return }
            postsPagination.setLoading(true)
        }

        let nextPage = postsPagination.currentPage + 1

        do {
            let response = try await CommunityService.shared.fetchPosts(
                communityId: community.id, perPage: 30, page: nextPage
            )
            postsPagination.append(response: response) { $0.map { CommunityPost(dto: $0) } }
        } catch {
            if reset { postsError = true }
        }
        postsPagination.setLoading(false)
    }

    private func loadMembers() async {
        do {
            let dto = try await CommunityService.shared.fetchCommunity(id: community.id)
            members = dto.members?.map { CommunityMember(dto: $0) } ?? []
        } catch {}
    }

    private func toggleJoin() {
        isJoined.toggle()
        Task {
            do {
                if isJoined {
                    _ = try await CommunityService.shared.join(communityId: community.id)
                } else {
                    _ = try await CommunityService.shared.leave(communityId: community.id)
                }
            } catch {
                isJoined.toggle()
            }
        }
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
        guard let index = postsPagination.items.firstIndex(where: { $0.id == post.id }) else { return }
        var updated = postsPagination.items[index]
        updated.isLiked.toggle()
        updated.likes += updated.isLiked ? 1 : -1
        postsPagination.updateItem(at: index, with: updated)

        Task {
            do {
                let response = try await CommunityService.shared.toggleLike(postId: post.id)
                if let idx = postsPagination.items.firstIndex(where: { $0.id == post.id }) {
                    var item = postsPagination.items[idx]
                    item.isLiked = response.isLiked
                    item.likes = response.likes
                    postsPagination.updateItem(at: idx, with: item)
                }
            } catch {
                if let idx = postsPagination.items.firstIndex(where: { $0.id == post.id }) {
                    var item = postsPagination.items[idx]
                    item.isLiked.toggle()
                    item.likes += item.isLiked ? 1 : -1
                    postsPagination.updateItem(at: idx, with: item)
                }
            }
        }
    }

    private func toggleBookmark(_ post: CommunityPost) {
        guard let index = postsPagination.items.firstIndex(where: { $0.id == post.id }) else { return }
        var updated = postsPagination.items[index]
        updated.isBookmarked.toggle()
        postsPagination.updateItem(at: index, with: updated)
    }
}

#Preview {
    NavigationStack {
        CommunityDetailView(community: CommunityMockData.detailCommunity)
    }
    .preferredColorScheme(.dark)
}
