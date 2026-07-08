import SwiftUI

struct SearchTopBar: View {
    @Binding var query: String
    var isFocused: FocusState<Bool>.Binding
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onBack) {
                AppIconView(icon: .back, size: 22)
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(width: 40, height: 40, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())

            HStack(spacing: 10) {
                AppIconView(icon: .search, size: 18)
                    .foregroundStyle(Color.appTextSecondary)

                TextField(
                    "",
                    text: $query,
                    prompt: Text("Search games...").foregroundStyle(Color.appTextSecondary)
                )
                .focused(isFocused)
                .foregroundStyle(Color.appTextPrimary)
                .font(.appBody(16))
                .tint(Color.appPrimary)
                .submitLabel(.search)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Capsule().fill(Color.appSurfaceCard))
            .overlay(Capsule().stroke(Color.appOutline, lineWidth: 1))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
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
