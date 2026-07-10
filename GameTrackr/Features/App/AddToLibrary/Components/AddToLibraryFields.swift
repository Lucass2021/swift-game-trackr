import SwiftUI

struct SectionLabel: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.appLabel(12))
            .tracking(0.8)
            .foregroundStyle(Color.appTextPrimary)
    }
}

struct FieldBoxStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 14)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.appSurfaceCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.appOutline, lineWidth: 1)
            )
    }
}

extension View {
    func fieldBox() -> some View {
        modifier(FieldBoxStyle())
    }
}

struct SheetNumberField: View {
    @Binding var value: String
    let placeholder: String

    var body: some View {
        TextField(
            "",
            text: $value,
            prompt: Text(placeholder).foregroundStyle(Color.appTextSecondary)
        )
        .keyboardType(.numberPad)
        .font(.appBody(16))
        .foregroundStyle(Color.appTextPrimary)
        .tint(Color.appPrimary)
        .fieldBox()
    }
}
