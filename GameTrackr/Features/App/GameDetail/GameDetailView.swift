import SwiftUI

struct GameDetailView: View {
    var slug: String?

    @Environment(AuthStore.self) private var authStore
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = GameDetailViewModel()
    @State private var showAddToLibrary = false

    private var game: GameDetail? {
        slug == nil ? GameDetailMockData.game : viewModel.game
    }

    var body: some View {
        GeometryReader { proxy in
            if let game {
                content(game: game, topInset: proxy.safeAreaInsets.top)
            } else {
                placeholder(topInset: proxy.safeAreaInsets.top)
            }
        }
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .task {
            guard let slug else { return }
            await viewModel.load(slug: slug)
        }
        .sheet(isPresented: $showAddToLibrary) {
            AddToLibrarySheet(gameTitle: game?.title ?? "")
        }
    }

    private func content(game: GameDetail, topInset: CGFloat) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                GameDetailHero(game: game, topInset: topInset, onBack: { dismiss() })

                header(game: game)
                    .padding(.horizontal, 20)

                if !game.screenshots.isEmpty {
                    GameScreenshotsSection(screenshots: game.screenshots)
                }

                GameAboutSection(about: game.about)

                if !game.specs.isEmpty {
                    GameSpecificationsSection(specs: game.specs)
                        .padding(.bottom, 32)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    private func placeholder(topInset: CGFloat) -> some View {
        VStack(spacing: 16) {
            if viewModel.failed {
                Text("Couldn't load this game.")
                    .font(.appBody(15))
                    .foregroundStyle(Color.appTextSecondary)
            } else {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topLeading) {
            Button { dismiss() } label: {
                AppIconView(icon: .back, size: 20)
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(width: 42, height: 42)
                    .contentShape(Circle())
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.horizontal, 16)
            .padding(.top, topInset + 8)
        }
    }

    private func header(game: GameDetail) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(game.title)
                .font(.appHeadline(30))
                .foregroundStyle(Color.appTextPrimary)
                .fixedSize(horizontal: false, vertical: true)

            FlowLayout(spacing: 8, lineSpacing: 8) {
                GameInfoChip(text: game.year)
                if let rating = game.rating {
                    GameInfoChip(text: String(format: "%.1f", rating), style: .rating)
                }
                ForEach(game.platforms, id: \.self) { GameInfoChip(text: $0) }
            }

            if !game.genres.isEmpty {
                FlowLayout(spacing: 8, lineSpacing: 8) {
                    ForEach(game.genres, id: \.self) { GameGenreChip(text: $0) }
                }
            }

            if !authStore.isGuest {
                PrimaryButton(title: "Add to library", icon: .addToLibrary) {
                    showAddToLibrary = true
                }
                .padding(.top, 2)
            }
        }
    }
}

#Preview {
    NavigationStack {
        GameDetailView()
    }
    .preferredColorScheme(.dark)
}
