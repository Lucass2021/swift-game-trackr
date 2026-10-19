import SwiftUI

private enum Constants {
    static let titleSize: CGFloat = 20
    static let countSize: CGFloat = 15
    static let closeButtonSize: CGFloat = 32
    static let closeIconSize: CGFloat = 16
    static let dividerThickness: CGFloat = 1
}

struct CommentsHeader: View {
    let total: Int
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Text("Comments")
                .font(.appHeadline(Constants.titleSize))
                .foregroundStyle(Color.appTextPrimary)

            Text("\(total)")
                .font(.appBody(Constants.countSize))
                .foregroundStyle(Color.appTextSecondary)

            Spacer()

            Button(action: onClose) {
                AppIconView(icon: .close, size: Constants.closeIconSize)
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(width: Constants.closeButtonSize, height: Constants.closeButtonSize)
                    .background(Circle().fill(Color.appBackground))
                    .contentShape(Circle())
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Close")
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.sm)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.appOutline)
                .frame(height: Constants.dividerThickness)
        }
    }
}

#Preview {
    CommentsHeader(total: 5, onClose: {})
        .background(Color.appSurfaceCard)
        .preferredColorScheme(.dark)
}
