import SwiftUI

private enum Constants {
    static let titleSize: CGFloat = 22
}

struct GameSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.appHeadline(Constants.titleSize))
            .foregroundStyle(Color.appTextPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    GameSectionHeader(title: "Screenshots")
        .padding(Spacing.md)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
