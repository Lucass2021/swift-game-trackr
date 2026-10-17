import SwiftUI

private enum Constants {
    static let cardWidth: CGFloat = 160
    static let cardHeight: CGFloat = 120
    static let borderWidth: CGFloat = 1
    static let addDash: [CGFloat] = [5, 4]
    static let addIconSize: CGFloat = 24
    static let titleSize: CGFloat = 14
    static let descriptionSize: CGFloat = 12
    static let addLabelSize: CGFloat = 13
}

struct ProfileSetupSection: View {
    let setups: [SetupItem]
    var onSelect: (SetupItem) -> Void = { _ in }
    var onAdd: () -> Void = {}

    var body: some View {
        if setups.isEmpty {
            ProfileSetupEmptyCard(onAdd: onAdd)
                .padding(.horizontal, Spacing.lg)
        } else {
            carousel
        }
    }

    private var carousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: Spacing.sm) {
                ForEach(setups) { item in
                    Button { onSelect(item) } label: {
                        card(item)
                    }
                    .buttonStyle(PressableButtonStyle())
                }

                Button(action: onAdd) {
                    addCard
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("Add setup")
            }
            .padding(.horizontal, Spacing.lg)
        }
    }

    private func card(_ item: SetupItem) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            SetupCover(setup: item)
                .frame(width: Constants.cardWidth, height: Constants.cardHeight)

            Text(item.title)
                .font(.appLabel(Constants.titleSize))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)

            Text(item.description)
                .font(.appBody(Constants.descriptionSize))
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: Constants.cardWidth, alignment: .leading)
        .contentShape(Rectangle())
    }

    private var addCard: some View {
        VStack(spacing: Spacing.xs) {
            AppIconView(icon: .plus, size: Constants.addIconSize)
                .foregroundStyle(Color.appPrimary)

            Text("Add setup")
                .font(.appBody(Constants.addLabelSize))
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(width: Constants.cardWidth, height: Constants.cardHeight)
        .background(
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .stroke(Color.appOutline, style: StrokeStyle(lineWidth: Constants.borderWidth, dash: Constants.addDash))
        )
        .contentShape(Rectangle())
    }
}

#Preview("With setups") {
    ProfileSetupSection(setups: ProfileMockData.setups)
        .padding(.vertical, Spacing.lg)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}

#Preview("Empty") {
    ProfileSetupSection(setups: [])
        .padding(.vertical, Spacing.lg)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
