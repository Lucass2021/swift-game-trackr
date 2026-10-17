import SwiftUI

private enum Constants {
    static let borderWidth: CGFloat = 1
    static let dash: [CGFloat] = [6, 5]
    static let iconBoxSize: CGFloat = 56
    static let iconSize: CGFloat = 26
    static let plusIconSize: CGFloat = 18
    static let iconBoxAlpha = 0.12
    static let titleSize: CGFloat = 15
    static let messageSize: CGFloat = 13
}

struct ProfileSetupEmptyCard: View {
    let onAdd: () -> Void

    var body: some View {
        Button(action: onAdd) {
            HStack(spacing: Spacing.sm) {
                AppIconView(icon: .devices, size: Constants.iconSize)
                    .foregroundStyle(Color.appPrimary)
                    .frame(width: Constants.iconBoxSize, height: Constants.iconBoxSize)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                            .fill(Color.appPrimary.opacity(Constants.iconBoxAlpha))
                    )

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("No setup yet")
                        .font(.appLabel(Constants.titleSize))
                        .foregroundStyle(Color.appTextPrimary)

                    Text("Add photos of your battle station, retro corner or handheld gear.")
                        .font(.appBody(Constants.messageSize))
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                AppIconView(icon: .plus, size: Constants.plusIconSize)
                    .foregroundStyle(Color.appPrimary)
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .fill(Color.appSurfaceCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .stroke(
                        Color.appOutline,
                        style: StrokeStyle(lineWidth: Constants.borderWidth, dash: Constants.dash)
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview {
    ProfileSetupEmptyCard(onAdd: {})
        .padding(Spacing.lg)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
