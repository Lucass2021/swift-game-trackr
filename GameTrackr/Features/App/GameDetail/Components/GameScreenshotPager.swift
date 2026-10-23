import SwiftUI

private enum Constants {
    static let closeButtonSize: CGFloat = 44
    static let closeIconSize: CGFloat = 20
    static let counterSize: CGFloat = 14
    static let screenshotRatio: CGFloat = 16.0 / 9.0
    static let controlAlpha = 0.5
    static let counterAlpha = 0.8
}

struct GameScreenshotPager: View {
    let screenshots: [GameScreenshot]
    let onClose: () -> Void

    @State private var current: Int

    init(screenshots: [GameScreenshot], startIndex: Int, onClose: @escaping () -> Void) {
        self.screenshots = screenshots
        self.onClose = onClose
        _current = State(initialValue: startIndex)
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { onClose() }

            TabView(selection: $current) {
                ForEach(Array(screenshots.enumerated()), id: \.offset) { index, shot in
                    Color.clear
                        .aspectRatio(Constants.screenshotRatio, contentMode: .fit)
                        .overlay {
                            GameCoverArt(start: shot.start, end: shot.end, url: shot.url)
                        }
                        .padding(.horizontal, Spacing.md)
                        .onTapGesture { onClose() }
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .overlay(alignment: .top) {
            HStack {
                Button(action: onClose) {
                    AppIconView(icon: .back, size: Constants.closeIconSize)
                        .foregroundStyle(Color.white)
                        .frame(width: Constants.closeButtonSize, height: Constants.closeButtonSize)
                        .background(Circle().fill(Color.black.opacity(Constants.controlAlpha)))
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("Close screenshots")

                Spacer()

                Text("\(current + 1) / \(screenshots.count)")
                    .font(.appLabel(Constants.counterSize))
                    .foregroundStyle(Color.white.opacity(Constants.counterAlpha))
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(Capsule().fill(Color.black.opacity(Constants.controlAlpha)))
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.sm)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    GameScreenshotPager(screenshots: FakeGameRepository.gameDetail.screenshots, startIndex: 1, onClose: {})
}
