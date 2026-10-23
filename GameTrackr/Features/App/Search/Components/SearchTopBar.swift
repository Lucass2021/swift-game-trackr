import SwiftUI

private enum Constants {
    static let backIconSize: CGFloat = 22
    static let backTapSize: CGFloat = 40
    static let searchIconSize: CGFloat = 18
    static let textSize: CGFloat = 16
    static let borderWidth: CGFloat = 1
}

struct SearchTopBar: View {
    @Binding var query: String
    var isFocused: FocusState<Bool>.Binding
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Button(action: onBack) {
                AppIconView(icon: .back, size: Constants.backIconSize)
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(width: Constants.backTapSize, height: Constants.backTapSize, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())

            HStack(spacing: Spacing.xs) {
                AppIconView(icon: .search, size: Constants.searchIconSize)
                    .foregroundStyle(Color.appTextSecondary)

                TextField(
                    "",
                    text: $query,
                    prompt: Text("Search games...").foregroundStyle(Color.appTextSecondary)
                )
                .focused(isFocused)
                .foregroundStyle(Color.appTextPrimary)
                .font(.appBody(Constants.textSize))
                .tint(Color.appPrimary)
                .submitLabel(.search)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(Capsule().fill(Color.appSurfaceCard))
            .overlay(Capsule().stroke(Color.appOutline, lineWidth: Constants.borderWidth))
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
        .background(Color.appBackground)
    }
}

#Preview {
    @Previewable @State var query = ""
    @Previewable @FocusState var focused: Bool
    SearchTopBar(query: $query, isFocused: $focused, onBack: {})
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
