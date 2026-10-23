import SwiftUI

private enum Constants {
    static let titleSize: CGFloat = 22
    static let countSize: CGFloat = 14
    static let loadMoreThreshold = 3
}

struct SearchResultsGrid: View {
    let viewModel: SearchViewModel
    var onGameSelect: (String) -> Void = { _ in }

    private var sectionTitle: String {
        if viewModel.isSearching { return "Results" }
        return viewModel.scope.isFiltered ? viewModel.scope.title : "Popular"
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                sectionHeader
                grid
            }
            .padding(.top, Spacing.xxs)
            .padding(.bottom, Spacing.xl)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var sectionHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(sectionTitle)
                .font(.appHeadline(Constants.titleSize))
                .foregroundStyle(Color.appTextPrimary)

            Spacer()

            Text("\(viewModel.total) result\(viewModel.total == 1 ? "" : "s")")
                .font(.appBody(Constants.countSize))
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(.horizontal, Spacing.lg)
    }

    private var grid: some View {
        VStack(spacing: 0) {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: Spacing.md), GridItem(.flexible(), spacing: Spacing.md)],
                alignment: .leading,
                spacing: Spacing.lg
            ) {
                ForEach(Array(viewModel.games.enumerated()), id: \.element.id) { index, game in
                    Button { onGameSelect(game.slug) } label: {
                        SearchResultCard(game: game)
                    }
                    .buttonStyle(PressableButtonStyle())
                    .onAppear {
                        if viewModel.canLoadMore, index >= viewModel.games.count - Constants.loadMoreThreshold {
                            Task { await viewModel.loadMore() }
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.lg)

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
    let viewModel = SearchViewModel(scope: .all, repository: FakeGameRepository(latency: .zero))
    return SearchResultsGrid(viewModel: viewModel)
        .task { await viewModel.loadIfNeeded() }
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
