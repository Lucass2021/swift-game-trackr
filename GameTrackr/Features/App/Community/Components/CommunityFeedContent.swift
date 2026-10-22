import SwiftUI

private enum Constants {
    static let bottomPadding: CGFloat = 96
    static let loadMoreThreshold = 3
    static let suggestionIndex = 0
    static let stateHeightRatio: CGFloat = 0.7
}

struct CommunityFeedContent: View {
    let viewModel: CommunityFeedViewModel
    let isGuest: Bool
    var onPostSelect: (CommunityPost) -> Void = { _ in }
    var onCommunitySelect: (Community) -> Void = { _ in }
    var onDiscover: () -> Void = {}

    private var filterSelection: Binding<String> {
        Binding(
            get: { viewModel.filter.rawValue },
            set: { title in
                guard let filter = CommunityFeedFilter(rawValue: title) else { return }
                Task { await viewModel.onFilterChange(filter) }
            }
        )
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Spacing.md) {
                CommunityChipRow(titles: CommunityFeedFilter.allCases.map(\.rawValue), selection: filterSelection)

                Group {
                    if viewModel.hasError {
                        stateView(isError: true)
                    } else if viewModel.isEmpty {
                        stateView(isError: false)
                    } else if viewModel.currentPage == 0 {
                        LoadingMoreIndicator()
                    } else {
                        posts
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }
            .padding(.bottom, Constants.bottomPadding)
        }
        .refreshable { await viewModel.refresh() }
    }

    private func stateView(isError: Bool) -> some View {
        EmptyState(
            icon: isError ? .info : .community,
            title: isError ? "Couldn't load feed" : "Your feed is quiet",
            message: isError
                ? "Check your connection\nand try again."
                : "Join a community to see posts\nfrom other players here.",
            actionTitle: isError ? "Try again" : "Discover communities",
            onAction: isError ? { Task { await viewModel.load() } } : onDiscover
        )
        .containerRelativeFrame(.vertical) { length, _ in length * Constants.stateHeightRatio }
    }

    private var posts: some View {
        VStack(spacing: Spacing.md) {
            ForEach(Array(viewModel.posts.enumerated()), id: \.element.id) { index, post in
                CommunityPostCard(
                    post: post,
                    isGuest: isGuest,
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

                if index == Constants.suggestionIndex, !isGuest, let suggestion = viewModel.suggestedCommunity {
                    SuggestedCommunityCard(
                        community: suggestion,
                        onSelect: { onCommunitySelect(suggestion) },
                        onJoin: { Task { await viewModel.onJoinSuggested() } }
                    )
                }
            }

            if viewModel.isLoadingMore {
                LoadingMoreIndicator()
            }

            if viewModel.loadMoreFailed {
                LoadMoreErrorRow(onRetry: { Task { await viewModel.loadMore() } })
            }
        }
    }
}

#Preview {
    let repository = FakeCommunityRepository(latency: .zero)
    let viewModel = CommunityFeedViewModel(
        feedRepository: FakeCommunityFeedRepository(remote: repository, latency: .zero),
        repository: repository,
        postUpdates: PostUpdates(),
        communityUpdates: CommunityUpdates()
    )
    return CommunityFeedContent(viewModel: viewModel, isGuest: false)
        .task { await viewModel.loadIfNeeded() }
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
