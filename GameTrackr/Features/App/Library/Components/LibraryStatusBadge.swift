import SwiftUI

struct LibraryStatusBadge: View {
    let status: LibraryStatus

    var body: some View {
        Text(status.rawValue.uppercased())
            .font(.appLabel(11))
            .tracking(0.6)
            .lineLimit(1)
            .fixedSize()
            .foregroundStyle(status.badgeForeground)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(status.badgeBackground))
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        ForEach(LibraryStatus.allCases) { LibraryStatusBadge(status: $0) }
    }
    .padding()
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
