import SwiftUI

struct AnticipatedCard: View {
    let game: AnticipatedGame

    private let cardWidth: CGFloat = 260

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            GameCoverArt(
                start: game.coverStart,
                end: game.coverEnd,
                width: cardWidth,
                height: 150
            )
            .overlay(alignment: .bottomLeading) {
                Text(game.badge)
                    .font(.appLabel(13))
                    .foregroundStyle(Color.appOnPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(game.badgeColor, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .padding(12)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(game.title)
                    .font(.appLabel(15))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)

                Text(game.subtitle)
                    .font(.appBody(13))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(1)
            }
            .frame(width: cardWidth, alignment: .leading)
        }
    }
}

#Preview {
    AnticipatedCard(game: HomeMockData.mostAnticipated[0])
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
