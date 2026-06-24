import SwiftUI

struct TitleWithSubtitle: View {
    let title: String
    let subTitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.appHeadline(32, weight: .heavy))
                .foregroundStyle(Color.appPrimary)
            Text(subTitle)
                .font(.appBody(17))
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    TitleWithSubtitle(title: "Title", subTitle: "Subtitle")
        .padding()
        .background(Color.appBackground)
}
