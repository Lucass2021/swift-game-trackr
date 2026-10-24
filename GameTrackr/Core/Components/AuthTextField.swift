import SwiftUI

private enum Constants {
    static let fieldHeight: CGFloat = 56
    static let borderWidth: CGFloat = 1
    static let focusedBorderWidth: CGFloat = 2
    static let leadingIconSize: CGFloat = 20
    static let revealIconSize: CGFloat = 22
}

struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: AppIcon?
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var contentType: UITextContentType?
    var error: String?

    @State private var isRevealed = false
    @FocusState private var isFocused: Bool

    private var borderColor: Color {
        if error != nil { return Color.appTertiary }
        return isFocused ? Color.appPrimary : Color.appOutline
    }

    private var borderWidth: CGFloat {
        (error != nil || isFocused) ? Constants.focusedBorderWidth : Constants.borderWidth
    }

    private var disablesAutocapitalization: Bool {
        isSecure || keyboardType == .emailAddress
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            HStack(spacing: Spacing.sm) {
                if let icon {
                    AppIconView(icon: icon, size: Constants.leadingIconSize)
                        .foregroundStyle(Color.appTextSecondary)
                        .accessibilityHidden(true)
                }

                Group {
                    if isSecure, !isRevealed {
                        SecureField(text: $text, prompt: prompt) {}
                            .textContentType(contentType)
                    } else {
                        TextField(text: $text, prompt: prompt) {}
                            .keyboardType(keyboardType)
                            .textInputAutocapitalization(disablesAutocapitalization ? .never : .sentences)
                            .autocorrectionDisabled(disablesAutocapitalization)
                            .textContentType(contentType)
                    }
                }
                .focused($isFocused)
                .font(.appBody(16))
                .foregroundStyle(Color.appTextPrimary)
                .tint(Color.appPrimary)

                if isSecure {
                    Button {
                        isRevealed.toggle()
                    } label: {
                        AppIconView(icon: isRevealed ? .eye : .eyeSlash, size: Constants.revealIconSize)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Spacing.md)
            .frame(height: Constants.fieldHeight)
            .contentShape(RoundedRectangle(cornerRadius: Radius.md))
            .onTapGesture { isFocused = true }
            .background(Color.appSurfaceCard)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md)
                    .stroke(borderColor, lineWidth: borderWidth)
            )

            if let error {
                Text(error)
                    .font(.appBody(13))
                    .foregroundStyle(Color.appTertiary)
                    .padding(.horizontal, Spacing.xxs)
            }
        }
    }

    private var prompt: Text {
        Text(placeholder).foregroundStyle(Color.appTextSecondary)
    }
}

#Preview {
    @Previewable @State var text = ""
    VStack(spacing: Spacing.md) {
        AuthTextField(placeholder: "Ex: CyberNinja", text: $text)
        AuthTextField(placeholder: "••••••••", text: $text, isSecure: true)
        AuthTextField(placeholder: "you@email.com", text: $text, error: ValidationMessage.emailRequired)
    }
    .padding()
    .background(Color.appBackground)
}
