import SwiftUI

private enum Constants {
    static let buttonSize: CGFloat = 40
    static let iconSize: CGFloat = 22
    static let menuIconSize: CGFloat = 18
    static let logoHeight: CGFloat = 24
    static let dividerThickness: CGFloat = 1
}

struct PostDetailTopBar: View {
    let isOwnPost: Bool
    let onBack: () -> Void
    let onDeleteRequest: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onBack) {
                icon(.back)
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Back")

            Spacer()

            Image("logo-wordmark")
                .resizable()
                .scaledToFit()
                .frame(height: Constants.logoHeight)

            Spacer()

            if isOwnPost {
                Menu {
                    Button(role: .destructive, action: onDeleteRequest) {
                        Label {
                            Text("Delete post")
                        } icon: {
                            AppIconView(icon: .trash, size: Constants.menuIconSize)
                        }
                    }
                } label: {
                    icon(.overflow)
                }
                .accessibilityLabel("More options")
            } else {
                Color.clear.frame(width: Constants.buttonSize, height: Constants.buttonSize)
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.appOutline)
                .frame(height: Constants.dividerThickness)
        }
    }

    private func icon(_ icon: AppIcon) -> some View {
        AppIconView(icon: icon, size: Constants.iconSize)
            .foregroundStyle(Color.appTextPrimary)
            .frame(width: Constants.buttonSize, height: Constants.buttonSize)
            .contentShape(Rectangle())
    }
}

#Preview {
    PostDetailTopBar(isOwnPost: true, onBack: {}, onDeleteRequest: {})
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
