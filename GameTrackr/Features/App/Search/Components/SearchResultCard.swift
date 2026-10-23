import SwiftUI

private enum Constants {
    static let coverAspectRatio: CGFloat = 0.72
    static let nameSize: CGFloat = 16
    static let detailSize: CGFloat = 14
    static let detailLineLimit = 2
    static let previewWidth: CGFloat = 180
}

struct SearchResultCard: View {
    let game: Game

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            GameCoverArt(start: game.coverStart, end: game.coverEnd, url: game.coverUrl)
                .aspectRatio(Constants.coverAspectRatio, contentMode: .fit)
                .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: Spacing.xxxs) {
                Text(game.name)
                    .font(.appLabel(Constants.nameSize))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)

                Text("\(game.year) • \(game.platformsLabel)")
                    .font(.appBody(Constants.detailSize))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(Constants.detailLineLimit)
            }
        }
    }
}

#Preview {
    SearchResultCard(game: HomeMockData.sampleGame)
        .frame(width: Constants.previewWidth)
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
