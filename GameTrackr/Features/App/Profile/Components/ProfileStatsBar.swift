import SwiftUI

private enum Constants {
    static let borderWidth: CGFloat = 1
    static let forwardIconSize: CGFloat = 14
    static let dividerHeight: CGFloat = 34
    static let valueSize: CGFloat = 19
    static let captionSize: CGFloat = 12
    static let labelSize: CGFloat = 11
    static let labelTracking: CGFloat = 0.8
}

struct ProfileStatsBar: View {
    let stats: ProfileStats
    var onTap: (() -> Void)?

    var body: some View {
        if let onTap {
            Button(action: onTap) {
                card
                    .overlay(alignment: .topTrailing) {
                        AppIconView(icon: .forward, size: Constants.forwardIconSize)
                            .foregroundStyle(Color.appTextSecondary)
                            .padding(Spacing.sm)
                    }
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("View full stats")
        } else {
            card
        }
    }

    private var card: some View {
        HStack(spacing: 0) {
            stat(value: "\(stats.totalGames)", label: "Games")
            divider
            stat(value: stats.hours.abbreviated, label: "Hours")
            divider
            stat(value: "\(stats.platinum)", label: "Platinum", caption: "\(stats.platinumRate)%")
        }
        .padding(.vertical, Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .stroke(Color.appOutline, lineWidth: Constants.borderWidth)
        )
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.appOutline)
            .frame(width: Constants.borderWidth, height: Constants.dividerHeight)
    }

    private func stat(value: String, label: String, caption: String? = nil) -> some View {
        VStack(spacing: Spacing.xxs) {
            HStack(alignment: .firstTextBaseline, spacing: Spacing.xxs) {
                Text(value)
                    .font(.appHeadline(Constants.valueSize))
                    .foregroundStyle(Color.appTextPrimary)

                if let caption {
                    Text(caption)
                        .font(.appBody(Constants.captionSize))
                        .foregroundStyle(Color.appPrimary)
                }
            }

            Text(label.uppercased())
                .font(.appLabel(Constants.labelSize))
                .kerning(Constants.labelTracking)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ProfileStatsBar(stats: ProfileMockData.stats, onTap: {})
        .padding(Spacing.lg)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
