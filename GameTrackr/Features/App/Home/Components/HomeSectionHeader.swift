import SwiftUI

private enum Constants {
    static let titleSize: CGFloat = 22
    static let viewAllSize: CGFloat = 15
}

struct HomeSectionHeader: View {
    let title: String
    let onViewAll: () -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.appHeadline(Constants.titleSize))
                .foregroundStyle(Color.appTextPrimary)

            Spacer()

            Button(action: onViewAll) {
                Text("View All")
                    .font(.appLabel(Constants.viewAllSize))
                    .foregroundStyle(Color.appPrimary)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(.horizontal, Spacing.lg)
    }
}

#Preview {
    HomeSectionHeader(title: "New Releases", onViewAll: {})
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
