import SwiftUI

private enum Constants {
    static let fieldHeight: CGFloat = 50
    static let reviewMinHeight: CGFloat = 110
    static let borderWidth: CGFloat = 1
    static let labelSize: CGFloat = 12
    static let labelTracking: CGFloat = 0.8
    static let inputSize: CGFloat = 16
    static let errorSize: CGFloat = 13
    static let reviewLines = 4 ... 6
}

struct AddToLibraryField<Content: View>: View {
    let label: String
    var error: String?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionLabel(text: label)
            content
            if let error {
                Text(error)
                    .font(.appBody(Constants.errorSize))
                    .foregroundStyle(Color.appTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SectionLabel: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.appLabel(Constants.labelSize, weight: .bold))
            .tracking(Constants.labelTracking)
            .foregroundStyle(Color.appTextPrimary)
    }
}

struct FieldBoxStyle: ViewModifier {
    var isError = false

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, Spacing.sm)
            .frame(height: Constants.fieldHeight)
            .fieldBorder(isError: isError)
    }
}

extension View {
    func fieldBox(isError: Bool = false) -> some View {
        modifier(FieldBoxStyle(isError: isError))
    }

    fileprivate func fieldBorder(isError: Bool = false) -> some View {
        background(
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .stroke(isError ? Color.appTertiary : Color.appOutline, lineWidth: Constants.borderWidth)
        )
    }
}

struct NumberField: View {
    @Binding var value: String
    let placeholder: String

    var body: some View {
        TextField("", text: $value, prompt: Text(placeholder).foregroundStyle(Color.appTextSecondary))
            .keyboardType(.numberPad)
            .font(.appBody(Constants.inputSize))
            .foregroundStyle(Color.appTextPrimary)
            .tint(Color.appPrimary)
            .fieldBox()
    }
}

struct ReviewField: View {
    @Binding var value: String
    let placeholder: String

    var body: some View {
        TextField("", text: $value, prompt: Text(placeholder).foregroundStyle(Color.appTextSecondary), axis: .vertical)
            .font(.appBody(Constants.inputSize))
            .foregroundStyle(Color.appTextPrimary)
            .tint(Color.appPrimary)
            .lineLimit(Constants.reviewLines)
            .padding(Spacing.sm)
            .frame(maxWidth: .infinity, minHeight: Constants.reviewMinHeight, alignment: .topLeading)
            .fieldBorder()
    }
}

#Preview {
    @Previewable @State var hours = ""
    @Previewable @State var review = ""
    VStack(spacing: Spacing.md) {
        AddToLibraryField(label: "Hours played") {
            NumberField(value: $hours, placeholder: "42")
        }
        AddToLibraryField(label: "Review", error: "Something is missing.") {
            ReviewField(value: $review, placeholder: "Write a short review...")
        }
    }
    .padding(Spacing.md)
    .background(Color.appBackground)
    .preferredColorScheme(.dark)
}
