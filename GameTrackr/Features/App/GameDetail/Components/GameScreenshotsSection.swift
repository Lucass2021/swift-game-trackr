import SwiftUI

struct GameScreenshotsSection: View {
    let screenshots: [GameScreenshot]
    @State private var selection: ScreenshotSelection?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            GameSectionHeader(title: "Screenshots")
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(screenshots.enumerated()), id: \.offset) { index, shot in
                        Button {
                            selection = ScreenshotSelection(index: index)
                        } label: {
                            screenshotThumb(shot)
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .fullScreenCover(item: $selection) { selection in
            ScreenshotPager(
                screenshots: screenshots,
                startIndex: selection.index,
                onClose: { self.selection = nil }
            )
        }
    }

    private func screenshotThumb(_ shot: GameScreenshot) -> some View {
        GameCoverArt(start: shot.start, end: shot.end, url: shot.url, width: 232, height: 132)
    }
}

private struct ScreenshotSelection: Identifiable {
    let id = UUID()
    let index: Int
}

private struct ScreenshotPager: View {
    let screenshots: [GameScreenshot]
    let startIndex: Int
    let onClose: () -> Void

    @State private var current: Int

    init(screenshots: [GameScreenshot], startIndex: Int, onClose: @escaping () -> Void) {
        self.screenshots = screenshots
        self.startIndex = startIndex
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
                        .aspectRatio(16.0 / 9.0, contentMode: .fit)
                        .overlay {
                            GameCoverArt(start: shot.start, end: shot.end, url: shot.url)
                        }
                        .padding(.horizontal, 16)
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
                    AppIconView(icon: .back, size: 20)
                        .foregroundStyle(Color.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.black.opacity(0.5)))
                }
                .buttonStyle(PressableButtonStyle())

                Spacer()

                Text("\(current + 1) / \(screenshots.count)")
                    .font(.appLabel(14))
                    .foregroundStyle(Color.white.opacity(0.8))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.black.opacity(0.5)))
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .preferredColorScheme(.dark)
    }
}
