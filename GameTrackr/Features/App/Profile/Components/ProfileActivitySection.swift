import SwiftUI

struct ProfileActivitySection: View {
    let events: [ActivityEvent]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                row(event)

                if index < events.count - 1 {
                    Divider()
                        .overlay(Color.appOutline)
                        .padding(.leading, 52)
                }
            }
        }
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.appOutline, lineWidth: 1)
        )
    }

    private func row(_ event: ActivityEvent) -> some View {
        HStack(spacing: 12) {
            AppIconView(icon: event.kind.icon, size: 18)
                .foregroundStyle(event.kind.tint)
                .frame(width: 36, height: 36)
                .background(Circle().fill(Color.appBackground))

            VStack(alignment: .leading, spacing: 2) {
                Text(event.kind.verb)
                    .font(.appBody(13))
                    .foregroundStyle(Color.appTextSecondary)

                Text(detail(for: event))
                    .font(.appLabel(15))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Text(event.timeAgo)
                .font(.appBody(13))
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }

    private func detail(for event: ActivityEvent) -> String {
        guard let extra = event.detail else { return event.gameTitle }
        return "\(event.gameTitle) \u{00B7} \(extra)"
    }
}

#Preview {
    ProfileActivitySection(events: ProfileMockData.activity)
        .padding(20)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
