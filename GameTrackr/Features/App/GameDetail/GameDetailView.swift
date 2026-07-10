import SwiftUI

struct GameDetailView: View {
    var game: GameDetail = GameDetailMockData.game
    var onExploreCommunity: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @State private var showAddToLibrary = false

    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    GameDetailHero(
                        game: game,
                        topInset: proxy.safeAreaInsets.top,
                        onBack: { dismiss() }
                    )

                    header
                        .padding(.horizontal, 20)

                    GameScreenshotsSection(screenshots: game.screenshots)

                    GameAboutSection(about: game.about)

                    GameCommunitySection(discussions: game.discussions, onSeeAll: onExploreCommunity)

                    GameSpecificationsSection(
                        specs: game.specs,
                        systemRequirements: game.systemRequirements,
                        showSystemRequirements: game.supportsPC
                    )
                    .padding(.bottom, 32)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showAddToLibrary) {
            AddToLibrarySheet(gameTitle: game.title)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(game.title)
                .font(.appHeadline(30))
                .foregroundStyle(Color.appTextPrimary)
                .fixedSize(horizontal: false, vertical: true)

            FlowLayout(spacing: 8, lineSpacing: 8) {
                GameInfoChip(text: game.year)
                GameInfoChip(text: String(format: "%.1f", game.rating), style: .rating)
                ForEach(game.platforms, id: \.self) { GameInfoChip(text: $0) }
            }

            FlowLayout(spacing: 8, lineSpacing: 8) {
                ForEach(game.genres, id: \.self) { GameGenreChip(text: $0) }
            }

            PrimaryButton(title: "Add to library", icon: .addToLibrary) {
                showAddToLibrary = true
            }
            .padding(.top, 2)
        }
    }
}

#Preview {
    NavigationStack {
        GameDetailView()
    }
    .preferredColorScheme(.dark)
}
