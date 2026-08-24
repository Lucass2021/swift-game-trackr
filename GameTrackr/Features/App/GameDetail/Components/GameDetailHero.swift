import SwiftUI

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
            .frame(height: 300 + topInset)
            .overlay { artwork }
            .clipped()
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [.clear, Color.appBackground],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 140)
            }
            .overlay(alignment: .top) {
                HStack {
                    Button(action: onBack) {
                        circleLabel(icon: .back)
                    }
                    .buttonStyle(PressableButtonStyle())

                    Spacer()

                    ShareLink(item: shareMessage) {
                        circleLabel(icon: .share)
                    }
                    .buttonStyle(PressableButtonStyle())
                }
                .padding(.horizontal, 16)
                .padding(.top, topInset + 8)
            }
    }

    @ViewBuilder
    private var artwork: some View {
        if let imageURL {
            AsyncImage(url: imageURL, transaction: Transaction(animation: .easeOut(duration: 0.2))) { phase in
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
        LinearGradient(
            colors: [game.coverStart, game.coverEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            AppIconView(icon: .brand, size: 96)
                .foregroundStyle(Color.white.opacity(0.12))
        }
    }

    private func circleLabel(icon: AppIcon) -> some View {
        AppIconView(icon: icon, size: 20)
            .foregroundStyle(Color.appTextPrimary)
            .frame(width: 42, height: 42)
            .background(Circle().fill(Color.black.opacity(0.45)))
            .overlay(Circle().stroke(Color.white.opacity(0.12), lineWidth: 1))
            .contentShape(Circle())
    }
}
