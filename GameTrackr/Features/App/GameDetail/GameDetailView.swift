import SwiftUI

private enum Constants {
    static let backButtonSize: CGFloat = 44
    static let backIconSize: CGFloat = 20
    static let loadingPreviewLatency: Duration = .seconds(3600)
}

struct GameDetailView: View {
    let slug: String
    var repository: GameRepository = RemoteGameRepository()

    @Environment(LibraryDependencies.self) private var library

    var body: some View {
        GameDetailScreen(slug: slug, repository: repository, library: library)
    }
}

private struct GameDetailScreen: View {
    let slug: String
    let library: LibraryDependencies

    @Environment(AuthStore.self) private var authStore
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: GameDetailViewModel
    @State private var addToLibrary: AddToLibraryViewModel?

    init(slug: String, repository: GameRepository, library: LibraryDependencies) {
        self.slug = slug
        self.library = library
        _viewModel = State(initialValue: GameDetailViewModel(
            slug: slug,
            repository: repository,
            libraryRepository: library.repository,
            libraryUpdates: library.libraryUpdates
        ))
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
        .toast(message: $viewModel.toastMessage, style: .success)
        .sheet(item: $addToLibrary) { addToLibraryViewModel in
            AddToLibrarySheet(viewModel: addToLibraryViewModel) {
                addToLibrary = nil
                viewModel.onAddedToLibrary()
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
                    isInLibrary: viewModel.isInLibrary,
                    onAddToLibrary: { openAddToLibrary(game) }
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

    private func openAddToLibrary(_ game: GameDetail) {
        addToLibrary = AddToLibraryViewModel(
            slug: slug,
            game: game,
            repository: library.repository,
            libraryUpdates: library.libraryUpdates
        )
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
    .environment(LibraryDependencies())
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
    .environment(LibraryDependencies())
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
    .environment(LibraryDependencies())
    .preferredColorScheme(.dark)
}
