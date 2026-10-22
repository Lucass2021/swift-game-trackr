import SwiftUI

struct HomeView: View {
    let viewModel: HomeViewModel
    var onViewAll: (SearchScope) -> Void = { _ in }
    var onGameSelect: (String) -> Void = { _ in }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                HomeFeedSection(
                    title: "New Releases",
                    feed: viewModel.newReleases,
                    onViewAll: { onViewAll(.newReleases) },
                    onRetry: { Task { await viewModel.onRetry(.newReleases) } },
                    onGameSelect: { onGameSelect($0.slug) },
                    card: { NewReleaseCard(game: $0) }
                )

                HomeFeedSection(
                    title: "Most Anticipated",
                    feed: viewModel.mostAnticipated,
                    onViewAll: { onViewAll(.mostAnticipated) },
                    onRetry: { Task { await viewModel.onRetry(.mostAnticipated) } },
                    onGameSelect: { onGameSelect($0.slug) },
                    card: { AnticipatedCard(game: $0) }
                )
            }
            .padding(.top, Spacing.sm)
            .padding(.bottom, Spacing.xl)
        }
        .background(Color.appBackground)
        .task { await viewModel.loadIfNeeded() }
        .refreshable { await viewModel.refresh() }
        .toast(message: Bindable(viewModel).toastMessage)
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(repository: FakeGameRepository(latency: .zero)))
        .preferredColorScheme(.dark)
}
