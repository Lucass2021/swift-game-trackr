import SwiftUI

private enum Constants {
    static let textSize: CGFloat = 16
    static let multiLineMinHeight: CGFloat = 110
    static let multiLineLimit = 3 ... 6
    static let borderWidth: CGFloat = 1
}

struct ProfileTextField: View {
    @Binding var text: String
    let placeholder: String
    var prefix: String?
    var singleLine = true

    var body: some View {
        if singleLine {
            HStack(spacing: 0) {
                if let prefix {
                    Text(prefix)
                        .font(.appBody(Constants.textSize))
                        .foregroundStyle(Color.appTextSecondary)
                }
                field
            }
            .fieldBox()
        } else {
            field
                .lineLimit(Constants.multiLineLimit)
                .padding(Spacing.sm)
                .frame(maxWidth: .infinity, minHeight: Constants.multiLineMinHeight, alignment: .topLeading)
                .background(
                    RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                        .fill(Color.appSurfaceCard)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                        .stroke(Color.appOutline, lineWidth: Constants.borderWidth)
                )
        }
    }

    private var field: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(placeholder).foregroundStyle(Color.appTextSecondary),
            axis: singleLine ? .horizontal : .vertical
        )
        .font(.appBody(Constants.textSize))
        .foregroundStyle(Color.appTextPrimary)
        .tint(Color.appPrimary)
    }
}

#Preview {
    @Previewable @State var name = ""
    @Previewable @State var username = "lucasdias"
    @Previewable @State var bio = ""
    VStack(spacing: Spacing.md) {
        ProfileTextField(text: $name, placeholder: "How should we call you?")
        ProfileTextField(text: $username, placeholder: "", prefix: "@")
        ProfileTextField(text: $bio, placeholder: "Tell other players...", singleLine: false)
    }
    .padding()
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
