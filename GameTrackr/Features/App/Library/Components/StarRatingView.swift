import SwiftUI

private enum Constants {
    static let maxRating = 5
    static let emptyStarAlpha = 0.55
    static let defaultSize: CGFloat = 15
}

struct StarRatingView: View {
    let rating: Int
    var size: CGFloat = Constants.defaultSize

    var body: some View {
        HStack(spacing: Spacing.xxxs) {
            ForEach(0 ..< Constants.maxRating, id: \.self) { index in
                Text(index < rating ? "\u{2605}" : "\u{2606}")
                    .font(.system(size: size))
                    .foregroundStyle(index < rating ? Color.appSecondary : Color.appTextSecondary
                        .opacity(Constants.emptyStarAlpha))
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.xs) {
        StarRatingView(rating: 0)
        StarRatingView(rating: 3)
        StarRatingView(rating: 5)
    }
    .padding()
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
