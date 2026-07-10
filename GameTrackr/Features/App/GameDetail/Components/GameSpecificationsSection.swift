import SwiftUI

struct GameSpecificationsSection: View {
    let specs: [GameSpec]
    let systemRequirements: [SystemRequirementTier]
    let showSystemRequirements: Bool

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            GameSectionHeader(title: "Specifications")

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(specs) { spec in
                    SpecCard(label: spec.label, value: spec.value)
                }
            }

            if showSystemRequirements {
                Text("System Requirements")
                    .font(.appHeadline(17))
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(.top, 6)

                VStack(spacing: 12) {
                    ForEach(systemRequirements) { tier in
                        RequirementTierCard(tier: tier)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

private struct SpecCard: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.appLabel(11))
                .tracking(0.8)
                .foregroundStyle(Color.appTextSecondary)
            Text(value)
                .font(.appLabel(15))
                .foregroundStyle(Color.appTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.appOutline, lineWidth: 1)
        )
    }
}

private struct RequirementTierCard: View {
    let tier: SystemRequirementTier

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.appPrimary)
                    .frame(width: 7, height: 7)
                Text(tier.name)
                    .font(.appLabel(14))
                    .foregroundStyle(Color.appTextPrimary)
            }

            VStack(spacing: 8) {
                ForEach(tier.items) { item in
                    HStack(alignment: .top, spacing: 12) {
                        Text(item.label)
                            .font(.appBody(13))
                            .foregroundStyle(Color.appTextSecondary)
                            .frame(width: 64, alignment: .leading)
                        Text(item.value)
                            .font(.appBody(13))
                            .foregroundStyle(Color.appTextPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.appOutline, lineWidth: 1)
        )
    }
}
