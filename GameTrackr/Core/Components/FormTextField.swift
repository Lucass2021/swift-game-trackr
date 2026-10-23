import SwiftUI

private enum Constants {
    static let textSize: CGFloat = 16
    static let defaultMultiLineMinHeight: CGFloat = 110
    static let defaultMultiLineLimit = 3 ... 6
    static let borderWidth: CGFloat = 1
}

struct FormTextField: View {
    @Binding var text: String
    let placeholder: String
    var prefix: String?
    var singleLine = true
    var multiLineMinHeight = Constants.defaultMultiLineMinHeight
    var multiLineLimit = Constants.defaultMultiLineLimit

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
                .lineLimit(multiLineLimit)
                .padding(Spacing.sm)
                .frame(maxWidth: .infinity, minHeight: multiLineMinHeight, alignment: .topLeading)
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
        FormTextField(text: $name, placeholder: "How should we call you?")
        FormTextField(text: $username, placeholder: "", prefix: "@")
        FormTextField(text: $bio, placeholder: "Tell other players...", singleLine: false)
    }
    .padding()
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
