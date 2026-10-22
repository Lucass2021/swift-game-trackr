import SwiftUI

struct CommunityDiscoverSegment: View {
    let viewModel: CommunityViewModel
    let isGuest: Bool
    var currentUserId: Int?
    var onCommunitySelect: (Community) -> Void = { _ in }
    var onCreateAccount: () -> Void = {}

    @State private var category = "All"
    @State private var communityToLeave: Community?

    var body: some View {
        if isGuest {
            EmptyState(
                icon: .community,
                title: "Account required",
                message: "Create an account to discover\nand join communities.",
                actionTitle: "Create an account",
                onAction: onCreateAccount
            )
            .frame(maxHeight: .infinity)
        } else {
            DiscoverCommunitiesView(
                category: $category,
                communities: viewModel.communities,
                currentUserId: currentUserId,
                isLoadingMore: viewModel.communitiesPagination.isLoadingMore,
                canLoadMore: viewModel.communitiesPagination.canLoadMore,
                onSelect: onCommunitySelect,
                onJoin: { community in
                    if community.isJoined {
                        communityToLeave = community
                    } else {
                        viewModel.joinCommunity(community)
                    }
                },
                onLoadMore: { Task { await viewModel.loadMoreCommunities() } }
            )
            .alert("Leave this community?", isPresented: leaveAlertBinding, presenting: communityToLeave) { community in
                Button("Leave", role: .destructive) { viewModel.leaveCommunity(community) }
                Button("Cancel", role: .cancel) {}
            } message: { _ in
                Text("You'll stop seeing its posts in your feed. You can join again anytime.")
            }
        }
    }

    private var leaveAlertBinding: Binding<Bool> {
        Binding(
            get: { communityToLeave != nil },
            set: { if !$0 { communityToLeave = nil } }
        )
    }
}

#Preview {
    let viewModel = CommunityViewModel(
        repository: FakeCommunityRepository(latency: .zero),
        communityUpdates: CommunityUpdates()
    )
    return CommunityDiscoverSegment(viewModel: viewModel, isGuest: false)
        .task { await viewModel.loadCommunities() }
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
