import SwiftUI

private enum Constants {
    static let loadMoreThreshold = 3
}

struct CommunityDetailPosts: View {
    let viewModel: CommunityDetailViewModel
    let isGuest: Bool
    var onPostSelect: (CommunityPost) -> Void = { _ in }
    var onCreatePost: () -> Void = {}

    var body: some View {
        if viewModel.hasError {
            EmptyState(
                icon: .info,
                title: "Couldn't load posts",
                message: "Check your connection\nand try again.",
                actionTitle: "Try again",
                onAction: { Task { await viewModel.load() } }
            )
            .frame(maxHeight: .infinity)
        } else if viewModel.isEmpty {
            EmptyState(
                icon: .community,
                title: "No posts yet",
                message: viewModel.isJoined
                    ? "Start the first discussion in this community."
                    : "Join this community to start posting.",
                actionTitle: viewModel.isJoined ? "Create post" : nil,
                onAction: viewModel.isJoined ? onCreatePost : nil
            )
            .frame(maxHeight: .infinity)
        } else if viewModel.currentPage == 0 {
            LoadingMoreIndicator()
        } else {
            list
        }
    }

    private var list: some View {
        VStack(spacing: Spacing.md) {
            ForEach(Array(viewModel.posts.enumerated()), id: \.element.id) { index, post in
                CommunityPostCard(
                    post: post,
                    isGuest: isGuest,
                    showsCommunityName: false,
                    onSelect: { onPostSelect(post) },
                    onLike: { Task { await viewModel.onLike(post.id) } },
                    onComment: { onPostSelect(post) },
                    onBookmark: { Task { await viewModel.onBookmark(post.id) } }
                )
                .onAppear {
                    if viewModel.canLoadMore, index >= viewModel.posts.count - Constants.loadMoreThreshold {
                        Task { await viewModel.loadMore() }
                    }
                }
            }

            if viewModel.isLoadingMore {
                LoadingMoreIndicator()
            }

            if viewModel.loadMoreFailed {
                LoadMoreErrorRow(onRetry: { Task { await viewModel.loadMore() } })
            }
        }
        .padding(.horizontal, Spacing.lg)
    }
}

#Preview {
    let repository = FakeCommunityRepository(latency: .zero)
    let viewModel = CommunityDetailViewModel(
        community: CommunityMockData.detailCommunity,
        repository: repository,
        feedRepository: FakeCommunityFeedRepository(remote: repository, latency: .zero),
        postUpdates: PostUpdates(),
        communityUpdates: CommunityUpdates()
    )
    return ScrollView {
        CommunityDetailPosts(viewModel: viewModel, isGuest: false)
    }
    .task { await viewModel.loadIfNeeded() }
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
