import SwiftUI

private enum Constants {
    static let cardWidth: CGFloat = 150
    static let coverHeight: CGFloat = 200
    static let nameSize: CGFloat = 15
    static let detailSize: CGFloat = 13
}

struct NewReleaseCard: View {
    let game: Game

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            GameCoverArt(
                start: game.coverStart,
                end: game.coverEnd,
                url: game.coverUrl,
                width: Constants.cardWidth,
                height: Constants.coverHeight
            )

            VStack(alignment: .leading, spacing: Spacing.xxxs) {
                Text(game.name)
                    .font(.appLabel(Constants.nameSize))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)

                Text(game.platformsLabel)
                    .font(.appBody(Constants.detailSize))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(1)
            }
            .frame(width: Constants.cardWidth, alignment: .leading)
        }
    }
}

#Preview {
    NewReleaseCard(game: HomeMockData.sampleGame)
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
