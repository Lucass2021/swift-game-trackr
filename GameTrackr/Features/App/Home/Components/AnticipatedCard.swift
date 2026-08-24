import SwiftUI

struct AnticipatedCard: View {
    let game: Game

    private let cardWidth: CGFloat = 260

    private var badgeColor: Color {
        game.releaseDate == nil ? .appSecondary : .appPrimary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            GameCoverArt(
                start: game.coverStart,
                end: game.coverEnd,
                url: game.coverUrl,
                width: cardWidth,
                height: 150
            )
            .overlay(alignment: .bottomLeading) {
                Text(game.year)
                    .font(.appLabel(13))
                    .foregroundStyle(Color.appOnPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(badgeColor, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .padding(12)
            }

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
    AnticipatedCard(game: HomeMockData.sampleGame)
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
