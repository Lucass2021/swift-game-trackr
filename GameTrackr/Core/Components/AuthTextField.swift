import SwiftUI

struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var contentType: UITextContentType? = nil
    var error: String? = nil

    @State private var isRevealed = false
    @FocusState private var isFocused: Bool

    private var borderColor: Color {
        if error != nil { return Color.appTertiary }
        return isFocused ? Color.appPrimary : Color.appOutline
    }

    private var borderWidth: CGFloat {
        (error != nil || isFocused) ? 2 : 1
    }

    private var disablesAutocapitalization: Bool {
        isSecure || keyboardType == .emailAddress
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                if let icon {
                    Image(systemName: icon)
                        .foregroundStyle(Color.appTextSecondary)
                        .frame(width: 20)
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
                        Image(systemName: isRevealed ? "eye" : "eye.slash")
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
            .frame(height: 56)
            .background(Color.appSurfaceCard)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor, lineWidth: borderWidth)
            )

            if let error {
                Text(error)
                    .font(.appBody(13))
                    .foregroundStyle(Color.appTertiary)
                    .padding(.horizontal, 4)
            }
        }
    }

    private var prompt: Text {
        Text(placeholder).foregroundStyle(Color.appTextSecondary)
    }
}

#Preview {
    @Previewable @State var text = ""
    VStack(spacing: 16) {
        AuthTextField(placeholder: "Ex: CyberNinja", text: $text)
        AuthTextField(placeholder: "••••••••", text: $text, isSecure: true)
    }
    .padding()
    .background(Color.appBackground)
}
