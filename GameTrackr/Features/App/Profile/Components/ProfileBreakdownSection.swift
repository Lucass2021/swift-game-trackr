import SwiftUI

extension LibraryStatus {
    var barTint: Color {
        switch self {
        case .playing: .appPrimary
        case .completed: .appSecondary
        case .backlog: .appTextSecondary
        case .platinum: .appTextPrimary
        case .abandoned: .appTertiary
        case .wishlist: .appSecondary.opacity(0.55)
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
        VStack(spacing: 12) {
            ForEach(breakdown) { item in
                Button {
                    onSelect(item.status)
                } label: {
                    row(item)
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.appOutline, lineWidth: 1)
        )
    }

    private func row(_ item: StatusCount) -> some View {
        HStack(spacing: 12) {
            Text(item.status.rawValue)
                .font(.appBody(14))
                .foregroundStyle(Color.appTextPrimary)
                .frame(width: 84, alignment: .leading)

            bar(fraction: Double(item.count) / Double(maxCount), tint: item.status.barTint)

            Text("\(item.count)")
                .font(.appLabel(14))
                .foregroundStyle(Color.appTextSecondary)
                .frame(width: 30, alignment: .trailing)
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
                    .frame(width: max(geo.size.width * fraction, 6))
            }
        }
        .frame(height: 7)
    }
}

#Preview {
    ProfileBreakdownSection(breakdown: ProfileMockData.breakdown)
        .padding(20)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
