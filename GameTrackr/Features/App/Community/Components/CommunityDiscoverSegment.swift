import SwiftUI

struct CommunityDiscoverSegment: View {
    let viewModel: DiscoverCommunitiesViewModel
    let isGuest: Bool
    var currentUserId: Int?
    var onCommunitySelect: (Community) -> Void = { _ in }
    var onCreateAccount: () -> Void = {}

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
            DiscoverCommunitiesContent(
                viewModel: viewModel,
                currentUserId: currentUserId,
                onCommunitySelect: onCommunitySelect
            )
            .alert(
                "Leave this community?",
                isPresented: leaveAlertBinding,
                presenting: viewModel.communityToLeave
            ) { _ in
                Button("Leave", role: .destructive) { Task { await viewModel.onLeaveConfirmed() } }
                Button("Cancel", role: .cancel) { viewModel.onLeaveDismissed() }
            } message: { _ in
                Text("You'll stop seeing its posts in your feed. You can join again anytime.")
            }
        }
    }

    private var leaveAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.communityToLeave != nil },
            set: { if !$0 { viewModel.onLeaveDismissed() } }
        )
    }
}

#Preview {
    let viewModel = DiscoverCommunitiesViewModel(
        repository: FakeDiscoverCommunitiesRepository(remote: FakeCommunityRepository(latency: .zero), latency: .zero),
        communityUpdates: CommunityUpdates()
    )
    return CommunityDiscoverSegment(viewModel: viewModel, isGuest: false)
        .task { await viewModel.loadIfNeeded() }
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
