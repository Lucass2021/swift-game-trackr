import SwiftUI

struct HomeView: View {
    var onViewAll: (SearchScope) -> Void = { _ in }
    var onGameSelect: () -> Void = {}

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
    }

    private var newReleasesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HomeSectionHeader(title: "New Releases", onViewAll: { onViewAll(.newReleases) })

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 14) {
                    ForEach(HomeMockData.newReleases) { release in
                        Button(action: onGameSelect) {
                            NewReleaseCard(release: release)
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
                        Button(action: onGameSelect) {
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
