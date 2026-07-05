import SwiftUI

struct HomeView: View {
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
            HomeSectionHeader(title: "New Releases", onViewAll: {})

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 14) {
                    ForEach(HomeMockData.newReleases) { release in
                        NewReleaseCard(release: release)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var anticipatedSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HomeSectionHeader(title: "Most Anticipated", onViewAll: {})

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 14) {
                    ForEach(HomeMockData.mostAnticipated) { game in
                        AnticipatedCard(game: game)
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
