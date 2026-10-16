import SwiftUI

private enum Constants {
    static let textSize: CGFloat = 15
}

struct LibraryStatsBar: View {
    let stats: LibraryStats

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Text("\(stats.totalGames) games")
                .foregroundStyle(Color.appTextPrimary)

            Text("\u{2022}")
                .foregroundStyle(Color.appTextSecondary)

            Text("\(stats.platinum) platinum")
                .foregroundStyle(Color.appTextSecondary)

            Spacer(minLength: 0)
        }
        .font(.appLabel(Constants.textSize))
    }
}

#Preview {
    LibraryStatsBar(stats: LibraryMockData.stats)
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
