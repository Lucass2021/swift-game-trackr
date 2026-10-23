import SwiftUI

private enum Constants {
    static let bodySize: CGFloat = 15
    static let bodyLineSpacing: CGFloat = 4
    static let toggleSize: CGFloat = 14
    static let caretSize: CGFloat = 12
    static let borderWidth: CGFloat = 1
    static let expandedRotation: Double = 180
    static let heightTolerance: CGFloat = 0.5
    static let shortAboutPreview = "A short summary that fits without Read more."
}

struct GameAboutSection: View {
    let about: String
    @State private var expanded = false
    @State private var fullHeight: CGFloat = 0
    @State private var fullyShownHeight: CGFloat = 0

    private var collapsible: Bool? {
        guard fullHeight > 0, fullyShownHeight > 0 else { return nil }
        return fullHeight > fullyShownHeight + Constants.heightTolerance
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            GameSectionHeader(title: "About")

            VStack(alignment: .leading, spacing: Spacing.sm) {
                aboutText
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(GameAboutLines.maxLines(expanded: expanded, collapsible: collapsible))
                    .background { measurements }

                if GameAboutLines.showsToggle(collapsible: collapsible) {
                    aboutToggle
                }
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .fill(Color.appSurfaceCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .stroke(Color.appOutline, lineWidth: Constants.borderWidth)
            )
        }
        .padding(.horizontal, Spacing.lg)
    }

    private var aboutText: some View {
        Text(about)
            .font(.appBody(Constants.bodySize))
            .lineSpacing(Constants.bodyLineSpacing)
    }

    private var measurements: some View {
        ZStack {
            aboutText
                .lineLimit(GameAboutLines.fullyShownMax)
                .fixedSize(horizontal: false, vertical: true)
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { fullyShownHeight = $0 }
            aboutText
                .fixedSize(horizontal: false, vertical: true)
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { fullHeight = $0 }
        }
        .hidden()
    }

    private var aboutToggle: some View {
        Button {
            withAnimation(.easeInOut(duration: Durations.short)) { expanded.toggle() }
        } label: {
            HStack(spacing: Spacing.xxs) {
                Text(expanded ? "Read less" : "Read more")
                    .font(.appLabel(Constants.toggleSize))
                AppIconView(icon: .caretDown, size: Constants.caretSize)
                    .rotationEffect(.degrees(expanded ? Constants.expandedRotation : 0))
            }
            .foregroundStyle(Color.appSecondary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GameAboutSection(about: FakeGameRepository.gameDetail.about)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

#Preview("Short") {
    GameAboutSection(about: Constants.shortAboutPreview)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
