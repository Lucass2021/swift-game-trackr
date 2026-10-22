import SwiftUI

struct HomeFeedSection<Card: View>: View {
    let title: String
    let feed: HomeFeed
    var onViewAll: () -> Void = {}
    var onRetry: () -> Void = {}
    var onGameSelect: (Game) -> Void = { _ in }
    @ViewBuilder let card: (Game) -> Card

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HomeSectionHeader(title: title, onViewAll: onViewAll)

            if feed.isWaiting {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: HomeSectionRetry.height)
            } else if feed.games.isEmpty {
                HomeSectionRetry(
                    message: feed.hasError ? "Couldn't load \(title)." : "Nothing in \(title) right now.",
                    action: onRetry
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: Spacing.sm) {
                        ForEach(feed.games) { game in
                            Button { onGameSelect(game) } label: {
                                card(game)
                            }
                            .buttonStyle(PressableButtonStyle())
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                }
            }
        }
    }
}

#Preview {
    HomeFeedSection(
        title: "New Releases",
        feed: HomeFeed(games: [HomeMockData.sampleGame], hasLoaded: true)
    ) { game in
        NewReleaseCard(game: game)
    }
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
