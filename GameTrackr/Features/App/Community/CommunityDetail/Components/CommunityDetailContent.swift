import SwiftUI

private enum Constants {
    static let bottomPadding: CGFloat = 96
    static let descriptionSize: CGFloat = 15
    static let descriptionMaxLines = 3
}

struct CommunityDetailContent: View {
    let community: Community
    @Bindable var viewModel: CommunityDetailViewModel
    let isGuest: Bool
    let isOwner: Bool
    var onPostSelect: (CommunityPost) -> Void = { _ in }
    var onCreatePost: () -> Void = {}
    var onMemberSelect: (CommunityMember) -> Void = { _ in }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                CommunityDetailHeader(community: community)

                Text(community.description)
                    .font(.appBody(Constants.descriptionSize))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(Constants.descriptionMaxLines)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, Spacing.lg)

                if !isGuest {
                    CommunityDetailActions(
                        isJoined: viewModel.isJoined,
                        isOwner: isOwner,
                        shareText: "Join the \(community.name) community on GameTrackr!",
                        onJoin: { Task { await viewModel.onJoinTap() } }
                    )
                    .padding(.horizontal, Spacing.lg)
                }

                CommunityStatsBar(community: community)
                    .padding(.horizontal, Spacing.lg)

                CommunityDetailTabs(selection: $viewModel.tab)

                tabContent
            }
            .padding(.bottom, Constants.bottomPadding)
            .remainingHeightContainer()
        }
        .refreshable { await viewModel.refresh() }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch viewModel.tab {
        case .posts:
            CommunityDetailPosts(
                viewModel: viewModel,
                isGuest: isGuest,
                onPostSelect: onPostSelect,
                onCreatePost: onCreatePost
            )
        case .about:
            CommunityAboutSection(
                community: community,
                isOwner: isOwner,
                onDelete: { viewModel.onDeleteRequest() }
            )
        case .members:
            if viewModel.membersFailed {
                EmptyState(
                    icon: .info,
                    title: "Couldn't load members",
                    message: "Check your connection and try again.",
                    actionTitle: "Try again",
                    onAction: { Task { await viewModel.retryMembers() } }
                )
            } else {
                CommunityMembersSection(members: viewModel.members, onSelect: onMemberSelect)
            }
        }
    }
}

#Preview {
    let viewModel = CommunityDetailViewModel(
        community: CommunityMockData.detailCommunity,
        repository: FakeCommunityRepository(latency: .zero)
    )
    return CommunityDetailContent(
        community: CommunityMockData.detailCommunity,
        viewModel: viewModel,
        isGuest: false,
        isOwner: true
    )
    .task { await viewModel.loadIfNeeded() }
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
