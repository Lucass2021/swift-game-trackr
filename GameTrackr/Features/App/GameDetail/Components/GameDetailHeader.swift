import SwiftUI

private enum Constants {
    static let titleSize: CGFloat = 30
    static let ratingFormat = "%.1f"
}

struct GameDetailHeader: View {
    let game: GameDetail
    let isGuest: Bool
    var isInLibrary = false
    let onAddToLibrary: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(game.title)
                .font(.appHeadline(Constants.titleSize))
                .foregroundStyle(Color.appTextPrimary)
                .fixedSize(horizontal: false, vertical: true)

            FlowLayout(spacing: Spacing.xs, lineSpacing: Spacing.xs) {
                GameInfoChip(text: game.year)
                if let rating = game.rating {
                    GameInfoChip(text: String(format: Constants.ratingFormat, rating), style: .rating)
                }
                ForEach(game.platforms, id: \.self) { GameInfoChip(text: $0) }
            }

            if !game.genres.isEmpty {
                FlowLayout(spacing: Spacing.xs, lineSpacing: Spacing.xs) {
                    ForEach(game.genres, id: \.self) { GameGenreChip(text: $0) }
                }
            }

            if !isGuest {
                if isInLibrary {
                    SecondaryButton(title: "In library", action: onAddToLibrary)
                } else {
                    PrimaryButton(title: "Add to library", icon: .addToLibrary, action: onAddToLibrary)
                }
            }
        }
    }
}

#Preview("Signed in") {
    GameDetailHeader(game: FakeGameRepository.gameDetail, isGuest: false, onAddToLibrary: {})
        .padding(Spacing.lg)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

#Preview("In library") {
    GameDetailHeader(game: FakeGameRepository.gameDetail, isGuest: false, isInLibrary: true, onAddToLibrary: {})
        .padding(Spacing.lg)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

#Preview("Guest") {
    GameDetailHeader(game: FakeGameRepository.gameDetail, isGuest: true, onAddToLibrary: {})
        .padding(Spacing.lg)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
