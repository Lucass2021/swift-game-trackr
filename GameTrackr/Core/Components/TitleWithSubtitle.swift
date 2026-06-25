import SwiftUI

struct TitleWithSubtitle: View {
    let title: String
    let subTitle: String
    var alignment: HorizontalAlignment = .leading

    var body: some View {
        VStack(alignment: alignment, spacing: 8) {
            Text(title)
                .font(.appHeadline(32, weight: .heavy))
                .foregroundStyle(Color.appPrimary)
            Text(subTitle)
                .font(.appBody(17))
                .foregroundStyle(Color.appTextSecondary)
        }
        .multilineTextAlignment(textAlignment)
        .frame(maxWidth: .infinity, alignment: frameAlignment)
    }

    private var textAlignment: TextAlignment {
        alignment == .center ? .center : (alignment == .trailing ? .trailing : .leading)
    }

    private var frameAlignment: Alignment {
        alignment == .center ? .center : (alignment == .trailing ? .trailing : .leading)
    }
}

#Preview {
    TitleWithSubtitle(title: "Title", subTitle: "Subtitle")
        .padding()
        .background(Color.appBackground)
}
