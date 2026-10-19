import SwiftUI

private enum Constants {
    static let labelSize: CGFloat = 13
    static let closeIconSize: CGFloat = 14
    static let dividerThickness: CGFloat = 1
}

struct ReplyIndicator: View {
    let author: String
    let onCancel: () -> Void

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Text("Replying to \(author)")
                .font(.appLabel(Constants.labelSize))
                .foregroundStyle(Color.appTextSecondary)

            Spacer()

            Button(action: onCancel) {
                AppIconView(icon: .close, size: Constants.closeIconSize)
                    .foregroundStyle(Color.appTextSecondary)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Cancel reply")
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.xs)
        .background(Color.appBackground)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.appOutline)
                .frame(height: Constants.dividerThickness)
        }
    }
}

#Preview {
    ReplyIndicator(author: "@QuestMaster", onCancel: {})
        .preferredColorScheme(.dark)
}
