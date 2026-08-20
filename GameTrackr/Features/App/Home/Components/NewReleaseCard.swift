import SwiftUI

struct NewReleaseCard: View {
    let game: Game

    private let cardWidth: CGFloat = 150

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            GameCoverArt(
                start: game.coverStart,
                end: game.coverEnd,
                url: game.coverUrl,
                width: cardWidth,
                height: 200
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(game.name)
                    .font(.appLabel(15))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)

                Text(game.platformsLabel)
                    .font(.appBody(13))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(1)
            }
            .frame(width: cardWidth, alignment: .leading)
        }
    }
}

#Preview {
    NewReleaseCard(game: HomeMockData.sampleGame)
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
