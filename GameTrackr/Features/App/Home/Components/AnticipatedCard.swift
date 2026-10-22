import SwiftUI

private enum Constants {
    static let cardWidth: CGFloat = 170
    static let coverHeight: CGFloat = 227
    static let nameSize: CGFloat = 15
    static let detailSize: CGFloat = 13
}

struct AnticipatedCard: View {
    let game: Game

    private var badgeColor: Color {
        game.releaseDate == nil ? .appSecondary : .appPrimary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            GameCoverArt(
                start: game.coverStart,
                end: game.coverEnd,
                url: game.coverUrl,
                width: Constants.cardWidth,
                height: Constants.coverHeight
            )
            .overlay(alignment: .bottomLeading) {
                Text(game.year)
                    .font(.appLabel(Constants.detailSize))
                    .foregroundStyle(Color.appOnPrimary)
                    .padding(.horizontal, Spacing.xs)
                    .padding(.vertical, Spacing.xxs)
                    .background(badgeColor, in: RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
                    .padding(Spacing.sm)
            }

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
    AnticipatedCard(game: HomeMockData.sampleGame)
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
