import SwiftUI

struct AchievementsView: View {
    var ownerName: String?

    @Environment(\.dismiss) private var dismiss

    @State private var filter: AchievementFilter = .all
    @State private var selected: GameAchievements?
    @State private var pagination = MockPaginationState(allItems: AchievementsMockData.games, pageSize: 3)

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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(item: $selected) { game in
            GameAchievementsView(game: game)
        }
    }

    @ViewBuilder
    private var content: some View {
        if visible.isEmpty {
            emptyState
        } else {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    if filter == .all {
                        AchievementsSummaryCard(games: pagination.items)
                            .padding(.bottom, 6)
                    }

                    ForEach(Array(visible.enumerated()), id: \.element.id) { index, game in
                        Button {
                            selected = game
                        } label: {
                            GameAchievementsRow(game: game)
                        }
                        .buttonStyle(PressableButtonStyle())
                        .onAppear {
                            if index >= visible.count - 2 {
                                Task { await pagination.loadNextPage() }
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

extension GameAchievements: Hashable {
    static func == (lhs: GameAchievements, rhs: GameAchievements) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
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
