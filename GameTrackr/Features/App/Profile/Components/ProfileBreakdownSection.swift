import SwiftUI

private enum Constants {
    static let borderWidth: CGFloat = 1
    static let labelWidth: CGFloat = 84
    static let countWidth: CGFloat = 30
    static let barHeight: CGFloat = 7
    static let barMinWidth: CGFloat = 6
    static let labelSize: CGFloat = 14
    static let wishlistAlpha = 0.55
}

extension LibraryStatus {
    var barTint: Color {
        switch self {
        case .playing: .appPrimary
        case .completed: .appSecondary
        case .backlog: .appTextSecondary
        case .platinum: .appTextPrimary
        case .abandoned: .appTertiary
        case .wishlist: .appSecondary.opacity(Constants.wishlistAlpha)
        }
    }
}

struct ProfileBreakdownSection: View {
    let breakdown: [StatusCount]
    var onSelect: (LibraryStatus) -> Void = { _ in }

    private var maxCount: Int {
        max(breakdown.map(\.count).max() ?? 0, 1)
    }

    var body: some View {
        VStack(spacing: Spacing.sm) {
            ForEach(breakdown) { item in
                Button {
                    onSelect(item.status)
                } label: {
                    row(item)
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .stroke(Color.appOutline, lineWidth: Constants.borderWidth)
        )
    }

    private func row(_ item: StatusCount) -> some View {
        HStack(spacing: Spacing.sm) {
            Text(item.status.rawValue)
                .font(.appBody(Constants.labelSize))
                .foregroundStyle(Color.appTextPrimary)
                .frame(width: Constants.labelWidth, alignment: .leading)

            bar(fraction: Double(item.count) / Double(maxCount), tint: item.status.barTint)

            Text("\(item.count)")
                .font(.appLabel(Constants.labelSize))
                .foregroundStyle(Color.appTextSecondary)
                .frame(width: Constants.countWidth, alignment: .trailing)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.status.rawValue), \(item.count) games")
    }

    private func bar(fraction: Double, tint: Color) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.appOutline)

                Capsule()
                    .fill(tint)
                    .frame(width: max(geo.size.width * fraction, Constants.barMinWidth))
            }
        }
        .frame(height: Constants.barHeight)
    }
}

#Preview {
    ProfileBreakdownSection(breakdown: ProfileMockData.breakdown)
        .padding(Spacing.lg)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
