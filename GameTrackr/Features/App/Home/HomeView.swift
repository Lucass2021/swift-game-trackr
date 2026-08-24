import SwiftUI

struct HomeView: View {
    var onViewAll: (SearchScope) -> Void = { _ in }
    var onGameSelect: (String?) -> Void = { _ in }

    @State private var viewModel = HomeViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                newReleasesSection
                anticipatedSection
            }
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
        .background(Color.appBackground)
        .task { await viewModel.loadNewReleases() }
        .refreshable { await viewModel.loadNewReleases() }
    }

    private var newReleasesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HomeSectionHeader(title: "New Releases", onViewAll: { onViewAll(.newReleases) })

            newReleasesContent
        }
    }

    @ViewBuilder
    private var newReleasesContent: some View {
        if viewModel.newReleases.isEmpty, !viewModel.hasLoadedNewReleases || viewModel.isLoadingNewReleases {
            ProgressView()
                .frame(maxWidth: .infinity)
                .frame(height: 240)
        } else if viewModel.newReleases.isEmpty {
            HomeSectionRetry(
                message: viewModel.newReleasesError == nil
                    ? "No new releases right now."
                    : "Couldn't load new releases.",
                action: { Task { await viewModel.loadNewReleases() } }
            )
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 14) {
                    ForEach(viewModel.newReleases) { game in
                        Button { onGameSelect(game.slug) } label: {
                            NewReleaseCard(game: game)
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var anticipatedSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HomeSectionHeader(title: "Most Anticipated", onViewAll: { onViewAll(.mostAnticipated) })

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 14) {
                    ForEach(HomeMockData.mostAnticipated) { game in
                        Button { onGameSelect(nil) } label: {
                            AnticipatedCard(game: game)
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
