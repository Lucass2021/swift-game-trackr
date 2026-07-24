import SwiftUI

struct YearBarChart: View {
    let years: [YearCount]

    private var maxCount: Int {
        max(years.map(\.count).max() ?? 0, 1)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 18) {
            ForEach(Array(years.enumerated()), id: \.element.id) { index, year in
                column(year, isCurrent: index == years.count - 1)
            }
        }
        .frame(height: 150, alignment: .bottom)
    }

    private func column(_ year: YearCount, isCurrent: Bool) -> some View {
        VStack(spacing: 10) {
            Spacer(minLength: 0)

            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(year.tint)
                .frame(height: max(110 * Double(year.count) / Double(maxCount), 12))

            Text(year.year)
                .font(.appLabel(12, weight: isCurrent ? .heavy : .regular))
                .foregroundStyle(isCurrent ? Color.appTextPrimary : Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(year.year), \(year.count) games")
    }
}

#Preview {
    YearBarChart(years: StatsMockData.stats.yearsCompleted)
        .padding(20)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
