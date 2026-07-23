import SwiftUI

struct ProfileStatsBar: View {
    let stats: ProfileStats

    var body: some View {
        HStack(spacing: 0) {
            stat(value: "\(stats.totalGames)", label: "Games")
            divider
            stat(value: stats.hours.abbreviated, label: "Hours")
            divider
            stat(value: "\(stats.platinum)", label: "Platinum", caption: "\(stats.platinumRate)%")
        }
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.appOutline, lineWidth: 1)
        )
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.appOutline)
            .frame(width: 1, height: 34)
    }

    private func stat(value: String, label: String, caption: String? = nil) -> some View {
        VStack(spacing: 5) {
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text(value)
                    .font(.appHeadline(19))
                    .foregroundStyle(Color.appTextPrimary)

                if let caption {
                    Text(caption)
                        .font(.appBody(12))
                        .foregroundStyle(Color.appPrimary)
                }
            }

            Text(label.uppercased())
                .font(.appLabel(11))
                .kerning(0.8)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ProfileStatsBar(stats: ProfileMockData.profile.stats)
        .padding(20)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
