import SwiftUI

private enum Constants {
    static let heroHeight: CGFloat = 300
    static let fadeHeight: CGFloat = 140
    static let brandSize: CGFloat = 96
    static let circleButtonSize: CGFloat = 44
    static let circleIconSize: CGFloat = 20
    static let borderWidth: CGFloat = 1
    static let brandAlpha = 0.12
    static let buttonFillAlpha = 0.45
    static let buttonBorderAlpha = 0.12
}

struct GameDetailHero: View {
    let game: GameDetail
    var topInset: CGFloat = 0
    let onBack: () -> Void

    private var shareMessage: String {
        "I found \(game.title) on GameTrackr"
    }

    private var imageURL: URL? {
        game.heroURL.flatMap(URL.init(string:))
    }

    var body: some View {
        Color.appSurfaceCard
            .frame(height: Constants.heroHeight + topInset)
            .overlay { artwork }
            .clipped()
            .overlay(alignment: .bottom) {
                LinearGradient(colors: [.clear, Color.appBackground], startPoint: .top, endPoint: .bottom)
                    .frame(height: Constants.fadeHeight)
            }
            .overlay(alignment: .top) {
                HStack {
                    Button(action: onBack) {
                        circleLabel(icon: .back)
                    }
                    .buttonStyle(PressableButtonStyle())
                    .accessibilityLabel("Back")

                    Spacer()

                    ShareLink(item: shareMessage) {
                        circleLabel(icon: .share)
                    }
                    .buttonStyle(PressableButtonStyle())
                    .accessibilityLabel("Share")
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, topInset + Spacing.xs)
            }
    }

    @ViewBuilder
    private var artwork: some View {
        if let imageURL {
            AsyncImage(
                url: imageURL,
                transaction: Transaction(animation: .easeOut(duration: Durations.short))
            ) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    placeholder
                default:
                    Color.appSurfaceCard
                }
            }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        LinearGradient(colors: [game.coverStart, game.coverEnd], startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay {
                AppIconView(icon: .brand, size: Constants.brandSize)
                    .foregroundStyle(Color.white.opacity(Constants.brandAlpha))
            }
    }

    private func circleLabel(icon: AppIcon) -> some View {
        AppIconView(icon: icon, size: Constants.circleIconSize)
            .foregroundStyle(Color.appTextPrimary)
            .frame(width: Constants.circleButtonSize, height: Constants.circleButtonSize)
            .background(Circle().fill(Color.black.opacity(Constants.buttonFillAlpha)))
            .overlay(Circle().stroke(
                Color.white.opacity(Constants.buttonBorderAlpha),
                lineWidth: Constants.borderWidth
            ))
            .contentShape(Circle())
    }
}

#Preview {
    GameDetailHero(game: FakeGameRepository.gameDetail, onBack: {})
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
