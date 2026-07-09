import SwiftUI

struct LibraryStatsBar: View {
    let stats: LibraryStats

    var body: some View {
        HStack(spacing: 8) {
            Text("\(stats.totalGames) games")
                .foregroundStyle(Color.appTextPrimary)

            Text("\u{2022}")
                .foregroundStyle(Color.appTextSecondary)

            Text("\(stats.platinum) platinum")
                .foregroundStyle(Color.appTextSecondary)

            Spacer(minLength: 0)
        }
        .font(.appLabel(15))
    }
}

#Preview {
    LibraryStatsBar(stats: LibraryMockData.stats)
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
