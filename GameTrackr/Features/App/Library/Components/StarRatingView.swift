import SwiftUI

struct StarRatingView: View {
    let rating: Int
    var size: CGFloat = 15

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0 ..< 5, id: \.self) { index in
                Text(index < rating ? "\u{2605}" : "\u{2606}")
                    .font(.system(size: size))
                    .foregroundStyle(index < rating ? Color.appSecondary : Color.appTextSecondary.opacity(0.55))
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 10) {
        StarRatingView(rating: 0)
        StarRatingView(rating: 3)
        StarRatingView(rating: 5)
    }
    .padding()
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
