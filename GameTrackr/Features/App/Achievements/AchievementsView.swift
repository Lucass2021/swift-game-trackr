import SwiftUI

struct AchievementsView: View {
    var ownerName: String?
    var repository: AchievementsRepository = FakeAchievementsRepository()

    @Environment(\.dismiss) private var dismiss

    @State private var filter: AchievementFilter = .all
    @State private var selectedGameId: Int?
    @State private var pagination = PaginationState<GameAchievements>()
    @State private var summary: AchievementsSummary?

    private enum Constants {
        static let gamesPageSize = 3
    }

    private var visible: [GameAchievements] {
        pagination.items.filter(filter.matches)
    }

    var body: some View {
        VStack(spacing: 0) {
            StatsTopBar(
                title: "Achievements",
                subtitle: ownerName,
                onBack: { dismiss() }
            )

            AchievementFilterChips(selection: $filter)
                .padding(.bottom, 4)

            content
                .task {
                    guard pagination.currentPage == 0 else { return }
                    await loadNextPage()
                }
                .task {
                    guard summary == nil else { return }
                    summary = try? await repository.fetchAchievementsSummary()
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(item: $selectedGameId) { gameId in
            GameAchievementsView(gameId: gameId, repository: repository)
        }
    }

    @ViewBuilder
    private var content: some View {
        if pagination.currentPage == 0 {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if visible.isEmpty {
            emptyState
        } else {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    if filter == .all, let summary {
                        AchievementsSummaryCard(summary: summary)
                            .padding(.bottom, 6)
                    }

                    ForEach(Array(visible.enumerated()), id: \.element.id) { index, game in
                        Button {
                            selectedGameId = game.id
                        } label: {
                            GameAchievementsRow(game: game)
                        }
                        .buttonStyle(PressableButtonStyle())
                        .onAppear {
                            if index >= visible.count - 2 {
                                Task { await loadNextPage() }
                            }
                        }
                    }

                    if pagination.isLoadingMore {
                        LoadingMoreIndicator()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
        }
    }

    private func loadNextPage() async {
        guard pagination.canLoadMore else { return }
        pagination.setLoading(true)
        if let page = try? await repository.fetchAchievementGames(
            page: pagination.currentPage + 1,
            perPage: Constants.gamesPageSize
        ) {
            pagination.append(page: page)
        }
        pagination.setLoading(false)
    }

    private var emptyState: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            AppIconView(icon: .trophy, size: 48)
                .foregroundStyle(Color.appPrimary)
                .frame(width: 104, height: 104)
                .background(Color.appSurfaceCard, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                .subtleBounce()

            Text("Nothing here yet")
                .font(.appHeadline(20))
                .foregroundStyle(Color.appTextPrimary)
                .padding(.top, 24)

            Text("Achievements from the games in your library show up here as you unlock them.")
                .font(.appBody(15))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
                .padding(.horizontal, 32)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Own") {
    NavigationStack {
        AchievementsView()
    }
    .preferredColorScheme(.dark)
}

#Preview("Other user") {
    NavigationStack {
        AchievementsView(ownerName: "Ana")
    }
    .preferredColorScheme(.dark)
}
