import SwiftUI

struct GameDetailHero: View {
    let game: GameDetail
    var topInset: CGFloat = 0
    let onBack: () -> Void

    private var shareMessage: String {
        "Check out \(game.title) on GameTrackr!"
    }

    var body: some View {
        LinearGradient(
            colors: [game.coverStart, game.coverEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            AppIconView(icon: .brand, size: 96)
                .foregroundStyle(Color.white.opacity(0.12))
        }
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
        .frame(height: 300 + topInset)
        .clipped()
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
