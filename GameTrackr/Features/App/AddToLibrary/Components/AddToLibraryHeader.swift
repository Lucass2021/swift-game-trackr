import SwiftUI

private enum Constants {
    static let coverSize: CGFloat = 56
    static let titleSize: CGFloat = 22
    static let subtitleSize: CGFloat = 14
}

struct AddToLibraryHeader: View {
    let gameTitle: String
    let coverStart: Color
    let coverEnd: Color

    var body: some View {
        HStack(spacing: Spacing.sm) {
            GameCoverArt(start: coverStart, end: coverEnd, width: Constants.coverSize, height: Constants.coverSize)

            VStack(alignment: .leading, spacing: Spacing.xxxs) {
                Text("Add to Library")
                    .font(.appHeadline(Constants.titleSize))
                    .foregroundStyle(Color.appTextPrimary)
                Text(gameTitle)
                    .font(.appBody(Constants.subtitleSize))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(1)
            }

            Spacer()
        }
    }
}

#Preview {
    AddToLibraryHeader(gameTitle: "Neon Ascent: Revival", coverStart: .coverVioletStart, coverEnd: .coverVioletEnd)
        .padding(Spacing.md)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
