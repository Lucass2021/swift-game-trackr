import SwiftUI

private enum Constants {
    static let borderWidth: CGFloat = 1
    static let dividerInset: CGFloat = 52
    static let iconBoxSize: CGFloat = 36
    static let iconSize: CGFloat = 18
    static let titleSize: CGFloat = 15
    static let detailSize: CGFloat = 13
}

struct ProfileActivitySection: View {
    let events: [ActivityEvent]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                row(event)

                if index < events.count - 1 {
                    Divider()
                        .overlay(Color.appOutline)
                        .padding(.leading, Constants.dividerInset)
                }
            }
        }
        .padding(.vertical, Spacing.xxs)
        .background(
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .stroke(Color.appOutline, lineWidth: Constants.borderWidth)
        )
    }

    private func row(_ event: ActivityEvent) -> some View {
        HStack(spacing: Spacing.sm) {
            AppIconView(icon: event.kind.icon, size: Constants.iconSize)
                .foregroundStyle(event.kind.tint)
                .frame(width: Constants.iconBoxSize, height: Constants.iconBoxSize)
                .background(Circle().fill(Color.appBackground))

            VStack(alignment: .leading, spacing: Spacing.xxxs) {
                Text(event.kind.verb)
                    .font(.appBody(Constants.detailSize))
                    .foregroundStyle(Color.appTextSecondary)

                Text(detail(for: event))
                    .font(.appLabel(Constants.titleSize))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
            }

            Spacer(minLength: Spacing.xs)

            Text(event.timeAgo)
                .font(.appBody(Constants.detailSize))
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.sm)
        .accessibilityElement(children: .combine)
    }

    private func detail(for event: ActivityEvent) -> String {
        guard let extra = event.detail else { return event.gameTitle }
        return "\(event.gameTitle) \u{00B7} \(extra)"
    }
}

#Preview {
    ProfileActivitySection(events: ProfileMockData.activity)
        .padding(Spacing.lg)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
