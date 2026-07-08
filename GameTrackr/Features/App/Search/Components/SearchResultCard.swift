import SwiftUI

struct SearchResultCard: View {
    let game: SearchGame

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            GameCoverArt(start: game.coverStart, end: game.coverEnd)
                .aspectRatio(0.72, contentMode: .fit)
                .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 3) {
                Text(game.title)
                    .font(.appLabel(16))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)

                Text("\(game.year) • \(game.platformsLabel)")
                    .font(.appBody(14))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
            }
        }
    }
}

#Preview {
    SearchResultCard(game: SearchMockData.games[0])
        .frame(width: 180)
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
