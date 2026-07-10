import SwiftUI

struct InteractiveStarRating: View {
    @Binding var rating: Int
    var size: CGFloat = 30

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1 ... 5, id: \.self) { index in
                Button {
                    rating = (rating == index) ? index - 1 : index
                } label: {
                    Text(index <= rating ? "\u{2605}" : "\u{2606}")
                        .font(.system(size: size))
                        .foregroundStyle(index <= rating ? Color.appSecondary : Color.appTextSecondary.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    @Previewable @State var rating = 4
    InteractiveStarRating(rating: $rating)
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
