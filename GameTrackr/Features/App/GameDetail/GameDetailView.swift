import SwiftUI

private enum Constants {
    static let backButtonSize: CGFloat = 44
    static let backIconSize: CGFloat = 20
    static let loadingPreviewLatency: Duration = .seconds(3600)
}

struct GameDetailView: View {
    @Environment(AuthStore.self) private var authStore
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: GameDetailViewModel
    @State private var showAddToLibrary = false

    init(slug: String, repository: GameRepository = RemoteGameRepository()) {
        _viewModel = State(initialValue: GameDetailViewModel(slug: slug, repository: repository))
    }

    var body: some View {
        GeometryReader { proxy in
            if let game = viewModel.game {
                content(game: game, topInset: proxy.safeAreaInsets.top)
            } else {
                placeholder(topInset: proxy.safeAreaInsets.top)
            }
        }
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .task { await viewModel.loadIfNeeded() }
        .sheet(isPresented: $showAddToLibrary) {
            if let game = viewModel.game {
                AddToLibrarySheet(gameTitle: game.title, coverStart: game.coverStart, coverEnd: game.coverEnd)
            }
        }
    }

    private func content(game: GameDetail, topInset: CGFloat) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                GameDetailHero(game: game, topInset: topInset, onBack: { dismiss() })

                GameDetailHeader(
                    game: game,
                    isGuest: authStore.isGuest,
                    onAddToLibrary: { showAddToLibrary = true }
                )
                .padding(.horizontal, Spacing.lg)

                if !game.screenshots.isEmpty {
                    GameScreenshotsSection(screenshots: game.screenshots)
                }

                GameAboutSection(about: game.about)

                if !game.specs.isEmpty {
                    GameSpecificationsSection(specs: game.specs)
                        .padding(.bottom, Spacing.xxl)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    private func placeholder(topInset: CGFloat) -> some View {
        Group {
            if viewModel.hasError {
                EmptyState(
                    icon: .info,
                    title: "Couldn't load this game",
                    message: "Check your connection and try again.",
                    actionTitle: "Try again",
                    onAction: { Task { await viewModel.load() } }
                )
            } else {
                ProgressView()
                    .tint(Color.appPrimary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topLeading) {
            Button { dismiss() } label: {
                AppIconView(icon: .back, size: Constants.backIconSize)
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(width: Constants.backButtonSize, height: Constants.backButtonSize)
                    .contentShape(Circle())
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Back")
            .padding(.horizontal, Spacing.md)
            .padding(.top, topInset + Spacing.xs)
        }
    }
}

#Preview("Loaded") {
    NavigationStack {
        GameDetailView(slug: "neon-ascent-revival", repository: FakeGameRepository())
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}

#Preview("Loading") {
    NavigationStack {
        GameDetailView(
            slug: "neon-ascent-revival",
            repository: FakeGameRepository(latency: Constants.loadingPreviewLatency)
        )
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}

#Preview("Error") {
    NavigationStack {
        GameDetailView(
            slug: "neon-ascent-revival",
            repository: FakeGameRepository(fetchGameFailure: APIError.networkFailure, latency: .zero)
        )
    }
    .environment(AuthStore())
    .preferredColorScheme(.dark)
}
