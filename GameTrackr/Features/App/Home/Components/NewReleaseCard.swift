import SwiftUI

struct NewReleaseCard: View {
    let release: NewRelease

    private let cardWidth: CGFloat = 150

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            GameCoverArt(
                start: release.coverStart,
                end: release.coverEnd,
                width: cardWidth,
                height: 200
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(release.title)
                    .font(.appLabel(15))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)

                Text(release.platforms)
                    .font(.appBody(13))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(1)
            }
            .frame(width: cardWidth, alignment: .leading)
        }
    }
}

#Preview {
    NewReleaseCard(release: HomeMockData.newReleases[0])
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
