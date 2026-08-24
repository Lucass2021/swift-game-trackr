import SwiftUI

struct HomeView: View {
    var onViewAll: (SearchScope) -> Void = { _ in }
    var onGameSelect: (String?) -> Void = { _ in }

    @State private var viewModel = HomeViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                section(title: "New Releases", scope: .newReleases, feed: viewModel.newReleases) { game in
                    NewReleaseCard(game: game)
                }

                section(title: "Most Anticipated", scope: .mostAnticipated, feed: viewModel.mostAnticipated) { game in
                    AnticipatedCard(game: game)
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
        .background(Color.appBackground)
        .task { await viewModel.loadAll() }
        .refreshable { await viewModel.loadAll(force: true) }
    }

    private func section(
        title: String,
        scope: SearchScope,
        feed: HomeFeed,
        @ViewBuilder card: @escaping (Game) -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HomeSectionHeader(title: title, onViewAll: { onViewAll(scope) })

            if feed.games.isEmpty, !feed.hasLoaded || feed.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)
            } else if feed.games.isEmpty {
                HomeSectionRetry(
                    message: feed.failed ? "Couldn't load \(title)." : "Nothing here right now.",
                    action: { Task { await viewModel.loadAll(force: true) } }
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 14) {
                        ForEach(feed.games) { game in
                            Button { onGameSelect(game.slug) } label: {
                                card(game)
                            }
                            .buttonStyle(PressableButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
