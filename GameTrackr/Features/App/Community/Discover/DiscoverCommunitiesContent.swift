import SwiftUI

private enum Constants {
    static let titleSize: CGFloat = 22
    static let dividerHeight: CGFloat = 1
    static let loadMoreThreshold = 3
}

struct DiscoverCommunitiesContent: View {
    let viewModel: DiscoverCommunitiesViewModel
    var currentUserId: Int?
    var onCommunitySelect: (Community) -> Void = { _ in }

    private var querySelection: Binding<String> {
        Binding(
            get: { viewModel.query },
            set: { viewModel.onQueryChange($0) }
        )
    }

    private var categorySelection: Binding<String> {
        Binding(
            get: { viewModel.category },
            set: { category in Task { await viewModel.onCategoryChange(category) } }
        )
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                CommunitySearchField(query: querySelection)
                    .padding(.horizontal, Spacing.lg)

                CommunityChipRow(titles: CommunityOptions.categories, selection: categorySelection)

                if viewModel.hasError {
                    EmptyState(
                        icon: .info,
                        title: "Couldn't load communities",
                        message: "Check your connection\nand try again.",
                        actionTitle: "Try again",
                        onAction: { Task { await viewModel.load() } }
                    )
                    .frame(maxHeight: .infinity)
                } else if viewModel.isEmpty {
                    EmptyState(
                        icon: .search,
                        title: "No communities found",
                        message: "Try a different search or category."
                    )
                    .frame(maxHeight: .infinity)
                } else if viewModel.currentPage == 0 {
                    LoadingMoreIndicator()
                } else {
                    allCommunities
                }
            }
            .padding(.bottom, Spacing.xl)
            .remainingHeightContainer()
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var allCommunities: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text("All communities")
                .font(.appHeadline(Constants.titleSize))
                .foregroundStyle(Color.appTextPrimary)
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.xs)

            ForEach(Array(viewModel.communities.enumerated()), id: \.element.id) { index, community in
                CommunityRow(
                    community: community,
                    isOwner: currentUserId != nil && community.authorId == currentUserId,
                    onSelect: { onCommunitySelect(community) },
                    onJoin: { Task { await viewModel.onJoinTap(community) } }
                )
                .onAppear {
                    if viewModel.canLoadMore, index >= viewModel.communities.count - Constants.loadMoreThreshold {
                        Task { await viewModel.loadMore() }
                    }
                }

                if index < viewModel.communities.count - 1 {
                    Rectangle()
                        .fill(Color.appOutline)
                        .frame(height: Constants.dividerHeight)
                        .padding(.horizontal, Spacing.lg)
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
    let viewModel = DiscoverCommunitiesViewModel(
        repository: FakeDiscoverCommunitiesRepository(remote: FakeCommunityRepository(latency: .zero), latency: .zero),
        communityUpdates: CommunityUpdates()
    )
    return DiscoverCommunitiesContent(viewModel: viewModel)
        .task { await viewModel.loadIfNeeded() }
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
