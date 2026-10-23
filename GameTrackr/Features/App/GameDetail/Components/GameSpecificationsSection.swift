import SwiftUI

private enum Constants {
    static let labelSize: CGFloat = 11
    static let labelTracking: CGFloat = 0.8
    static let valueSize: CGFloat = 15
    static let borderWidth: CGFloat = 1
    static let columns = 2
}

struct GameSpecificationsSection: View {
    let specs: [GameSpec]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            GameSectionHeader(title: "Specifications")

            VStack(spacing: Spacing.sm) {
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    HStack(spacing: Spacing.sm) {
                        ForEach(row) { spec in
                            SpecCard(spec: spec)
                        }
                        ForEach(row.count ..< Constants.columns, id: \.self) { _ in
                            Spacer()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
    }

    private var rows: [[GameSpec]] {
        stride(from: 0, to: specs.count, by: Constants.columns).map {
            Array(specs[$0 ..< min($0 + Constants.columns, specs.count)])
        }
    }
}

private struct SpecCard: View {
    let spec: GameSpec

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(spec.label.uppercased())
                .font(.appLabel(Constants.labelSize))
                .tracking(Constants.labelTracking)
                .foregroundStyle(Color.appTextSecondary)
            Text(spec.value)
                .font(.appLabel(Constants.valueSize))
                .foregroundStyle(Color.appTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Spacing.sm)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .stroke(Color.appOutline, lineWidth: Constants.borderWidth)
        )
    }
}

#Preview {
    GameSpecificationsSection(specs: FakeGameRepository.gameDetail.specs)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
