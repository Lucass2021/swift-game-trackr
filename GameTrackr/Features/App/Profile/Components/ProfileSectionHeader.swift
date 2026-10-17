import SwiftUI

private enum Constants {
    static let titleSize: CGFloat = 20
    static let actionSize: CGFloat = 15
}

struct ProfileSectionHeader: View {
    let title: String
    var actionTitle: String?
    var onAction: () -> Void = {}

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.appHeadline(Constants.titleSize))
                .foregroundStyle(Color.appTextPrimary)

            Spacer()

            if let actionTitle {
                Button(action: onAction) {
                    Text(actionTitle)
                        .font(.appLabel(Constants.actionSize))
                        .foregroundStyle(Color.appPrimary)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding(.horizontal, Spacing.lg)
    }
}

#Preview {
    ProfileSectionHeader(title: "Favorites", actionTitle: "View all")
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
