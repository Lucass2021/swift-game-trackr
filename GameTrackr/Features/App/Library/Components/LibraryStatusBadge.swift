import SwiftUI

private enum Constants {
    static let labelSize: CGFloat = 11
    static let labelLetterSpacing: CGFloat = 0.6
}

struct LibraryStatusBadge: View {
    let status: LibraryStatus

    var body: some View {
        Text(status.rawValue.uppercased())
            .font(.appLabel(Constants.labelSize))
            .tracking(Constants.labelLetterSpacing)
            .lineLimit(1)
            .fixedSize()
            .foregroundStyle(status.badgeForeground)
            .padding(.horizontal, Spacing.xs)
            .padding(.vertical, Spacing.xxs)
            .background(Capsule().fill(status.badgeBackground))
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.sm) {
        ForEach(LibraryStatus.allCases) { LibraryStatusBadge(status: $0) }
    }
    .padding()
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
