import SwiftUI

private enum Constants {
    static let bodySize: CGFloat = 15
    static let bodyLineSpacing: CGFloat = 4
    static let toggleSize: CGFloat = 14
    static let caretSize: CGFloat = 12
    static let borderWidth: CGFloat = 1
    static let collapsedLines = 3
    static let expandedRotation: Double = 180
}

struct GameAboutSection: View {
    let about: String
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            GameSectionHeader(title: "About")

            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(about)
                    .font(.appBody(Constants.bodySize))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineSpacing(Constants.bodyLineSpacing)
                    .lineLimit(expanded ? nil : Constants.collapsedLines)

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
}

#Preview {
    GameAboutSection(about: FakeGameRepository.gameDetail.about)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
