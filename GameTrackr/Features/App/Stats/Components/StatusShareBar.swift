import SwiftUI

struct StatusShareBar: View {
    let shares: [StatusShare]

    private var total: Double {
        max(Double(shares.reduce(0) { $0 + $1.percent }), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            GeometryReader { geo in
                HStack(spacing: 0) {
                    ForEach(shares) { share in
                        Rectangle()
                            .fill(share.status.barTint)
                            .frame(width: geo.size.width * Double(share.percent) / total)
                    }
                }
            }
            .frame(height: 26)
            .clipShape(Capsule())

            HStack(alignment: .top, spacing: 18) {
                ForEach(shares) { share in
                    legend(share)
                }
                Spacer(minLength: 0)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func legend(_ share: StatusShare) -> some View {
        HStack(alignment: .top, spacing: 7) {
            Circle()
                .fill(share.status.barTint)
                .frame(width: 8, height: 8)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 1) {
                Text("\(share.percent)%")
                    .font(.appLabel(13))
                    .foregroundStyle(Color.appTextPrimary)
                Text(share.status.rawValue)
                    .font(.appBody(12))
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
    }
}

#Preview {
    StatusShareBar(shares: StatsMockData.stats.statusShare)
        .padding(20)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
