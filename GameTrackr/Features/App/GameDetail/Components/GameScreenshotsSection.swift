import SwiftUI

private enum Constants {
    static let thumbWidth: CGFloat = 232
    static let thumbHeight: CGFloat = 132
}

struct GameScreenshotsSection: View {
    let screenshots: [GameScreenshot]
    @State private var selection: ScreenshotSelection?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            GameSectionHeader(title: "Screenshots")
                .padding(.horizontal, Spacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(Array(screenshots.enumerated()), id: \.offset) { index, shot in
                        Button {
                            selection = ScreenshotSelection(index: index)
                        } label: {
                            GameCoverArt(
                                start: shot.start,
                                end: shot.end,
                                url: shot.url,
                                width: Constants.thumbWidth,
                                height: Constants.thumbHeight
                            )
                        }
                        .buttonStyle(PressableButtonStyle())
                        .accessibilityLabel("Open screenshot")
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }
        }
        .fullScreenCover(item: $selection) { selection in
            GameScreenshotPager(
                screenshots: screenshots,
                startIndex: selection.index,
                onClose: { self.selection = nil }
            )
        }
    }
}

private struct ScreenshotSelection: Identifiable {
    let id = UUID()
    let index: Int
}

#Preview {
    GameScreenshotsSection(screenshots: FakeGameRepository.gameDetail.screenshots)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
