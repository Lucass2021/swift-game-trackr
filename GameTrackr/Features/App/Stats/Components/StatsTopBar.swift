import SwiftUI

private enum Constants {
    static let iconSize: CGFloat = 22
    static let buttonSize: CGFloat = 40
    static let titleSize: CGFloat = 22
    static let subtitleSize: CGFloat = 13
}

struct StatsTopBar: View {
    let title: String
    var subtitle: String?
    let onBack: () -> Void
    var shareText: String?

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Button(action: onBack) {
                AppIconView(icon: .back, size: Constants.iconSize)
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(width: Constants.buttonSize, height: Constants.buttonSize, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Back")

            VStack(alignment: .leading, spacing: Spacing.xxxs) {
                Text(title)
                    .font(.appHeadline(Constants.titleSize))
                    .foregroundStyle(Color.appTextPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.appBody(Constants.subtitleSize))
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }

            Spacer(minLength: Spacing.xs)

            if let shareText {
                ShareLink(item: shareText) {
                    AppIconView(icon: .share, size: Constants.iconSize)
                        .foregroundStyle(Color.appSecondary)
                        .frame(width: Constants.buttonSize, height: Constants.buttonSize, alignment: .trailing)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("Share stats")
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
        .background(Color.appBackground)
    }
}

#Preview {
    StatsTopBar(title: "Your Stats", onBack: {})
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
