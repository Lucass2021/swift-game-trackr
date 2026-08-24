import SwiftUI

struct GameSpecificationsSection: View {
    let specs: [GameSpec]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            GameSectionHeader(title: "Specifications")

            VStack(spacing: 12) {
                ForEach(specs) { spec in
                    SpecCard(label: spec.label, value: spec.value)
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
        .frame(maxWidth: .infinity, alignment: .leading)
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
