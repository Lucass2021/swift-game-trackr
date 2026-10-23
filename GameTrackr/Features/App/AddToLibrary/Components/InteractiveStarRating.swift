import SwiftUI

private enum Constants {
    static let starSize: CGFloat = 30
    static let maxRating = 5
    static let emptyAlpha = 0.5
    static let filledStar = "\u{2605}"
    static let emptyStar = "\u{2606}"
    static let previewRating = 4
}

struct InteractiveStarRating: View {
    @Binding var rating: Int

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(1 ... Constants.maxRating, id: \.self) { index in
                Button {
                    rating = (rating == index) ? index - 1 : index
                } label: {
                    Text(index <= rating ? Constants.filledStar : Constants.emptyStar)
                        .font(.system(size: Constants.starSize))
                        .foregroundStyle(
                            index <= rating ? Color.appSecondary : Color.appTextSecondary.opacity(Constants.emptyAlpha)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Rate \(index) of \(Constants.maxRating) stars")
            }
        }
    }
}

#Preview {
    @Previewable @State var rating = Constants.previewRating
    InteractiveStarRating(rating: $rating)
        .padding(Spacing.md)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
