import SwiftUI

private enum Constants {
    static let caretSize: CGFloat = 16
    static let textSize: CGFloat = 16
    static let dropdownOffset: CGFloat = 58
    static let dropdownZIndex: Double = 20
    static let borderWidth: CGFloat = 1
    static let shadowAlpha = 0.4
    static let shadowRadius: CGFloat = 16
    static let shadowY: CGFloat = 8
    static let openRotation: Double = 180
}

struct PlatformPicker: View {
    @Binding var selection: String
    let options: [String]

    @State private var isOpen = false

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: Durations.fast)) { isOpen.toggle() }
        } label: {
            HStack {
                Text(selection)
                    .font(.appBody(Constants.textSize))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                AppIconView(icon: .caretDown, size: Constants.caretSize)
                    .foregroundStyle(Color.appTextSecondary)
                    .rotationEffect(.degrees(isOpen ? Constants.openRotation : 0))
            }
            .fieldBox()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .topLeading) {
            if isOpen {
                dropdown
                    .offset(y: Constants.dropdownOffset)
                    .zIndex(Constants.dropdownZIndex)
            }
        }
        .zIndex(isOpen ? Constants.dropdownZIndex : 0)
    }

    private var dropdown: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.element) { index, option in
                Button {
                    selection = option
                    withAnimation(.easeInOut(duration: Durations.fast)) { isOpen = false }
                } label: {
                    Text(option)
                        .font(.appBody(Constants.textSize))
                        .foregroundStyle(option == selection ? Color.appPrimary : Color.appTextPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.sm)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if index < options.count - 1 {
                    Divider().overlay(Color.appOutline)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .fill(Color.appSurfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .stroke(Color.appOutline, lineWidth: Constants.borderWidth)
        )
        .shadow(color: .black.opacity(Constants.shadowAlpha), radius: Constants.shadowRadius, y: Constants.shadowY)
    }
}

#Preview {
    @Previewable @State var selection = "PS5"
    PlatformPicker(selection: $selection, options: ["PS5", "PC"])
        .padding(Spacing.md)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
