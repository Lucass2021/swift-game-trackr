import SwiftUI

private enum Constants {
    static let chartHeight: CGFloat = 150
    static let maxBarHeight: CGFloat = 110
    static let minBarHeight: CGFloat = 12
    static let labelSize: CGFloat = 12
}

struct YearBarChart: View {
    let years: [YearCount]

    private var maxCount: Int {
        max(years.map(\.count).max() ?? 0, 1)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: Spacing.md) {
            ForEach(Array(years.enumerated()), id: \.element.id) { index, year in
                column(year, isCurrent: index == years.count - 1)
            }
        }
        .frame(height: Constants.chartHeight, alignment: .bottom)
    }

    private func column(_ year: YearCount, isCurrent: Bool) -> some View {
        VStack(spacing: Spacing.xs) {
            Spacer(minLength: 0)

            RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                .fill(year.tint)
                .frame(height: max(
                    Constants.maxBarHeight * Double(year.count) / Double(maxCount),
                    Constants.minBarHeight
                ))

            Text(year.year)
                .font(.appLabel(Constants.labelSize, weight: isCurrent ? .heavy : .regular))
                .foregroundStyle(isCurrent ? Color.appTextPrimary : Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(year.year), \(year.count) games")
    }
}

#Preview {
    YearBarChart(years: StatsMockData.stats.yearsCompleted)
        .padding(Spacing.lg)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
