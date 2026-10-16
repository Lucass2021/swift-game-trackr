import SwiftUI

struct SetupFormField<Content: View>: View {
    let label: String
    var counter: String?
    var error: String?
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                SectionLabel(text: label)
                Spacer()
                if let counter {
                    Text(counter)
                        .font(.appBody(12))
                        .foregroundStyle(Color.appTextSecondary)
                }
            }

            content()

            if let error {
                Text(error)
                    .font(.appBody(13))
                    .foregroundStyle(Color.appTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SetupTextField: View {
    @Binding var text: String
    let placeholder: String
    var isMultiline = false

    var body: some View {
        if isMultiline {
            TextField("", text: $text, prompt: prompt, axis: .vertical)
                .font(.appBody(16))
                .foregroundStyle(Color.appTextPrimary)
                .tint(Color.appPrimary)
                .lineLimit(3 ... 6)
                .padding(14)
                .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.appSurfaceCard)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.appOutline, lineWidth: 1)
                )
        } else {
            TextField("", text: $text, prompt: prompt)
                .font(.appBody(16))
                .foregroundStyle(Color.appTextPrimary)
                .tint(Color.appPrimary)
                .submitLabel(.next)
                .fieldBox()
        }
    }

    private var prompt: Text {
        Text(placeholder).foregroundStyle(Color.appTextSecondary)
    }
}

#Preview {
    SetupFormField(label: "Title", error: "Title is required") {
        SetupTextField(text: .constant(""), placeholder: "Main Battle Station")
    }
    .padding(20)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
